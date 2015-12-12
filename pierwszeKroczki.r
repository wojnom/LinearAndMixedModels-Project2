setwd("/Users/Marcin/Documents/R/modelemieszaneiliniowe/SecondProject")

library("lme4")
library("data.table")
library("ggplot2")
library("reshape")
library("dplyr")
head(load("dendriticSpines.rda"))

head(dendriticSpines)
summary(dendriticSpines)

length(levels(as.factor(dendriticSpines[,3])))
length(levels(as.factor(dendriticSpines[,2])))
length(levels(as.factor(dendriticSpines[,1])))

tabelka <- dendriticSpines

# dlugosc spajnow dla kazdego leczenie
dlugoscSpajnowPerLeczenie <- ggplot(data = tabelka, aes(x = treatment, y = length)) +
    geom_boxplot(aes(fill = treatment))

# srednia dlugosc spajnow dla kazdego z 3 typow myszy
dlugoscSpajnowPerTypMyszy <- ggplot(data = tabelka, aes(x = mouse, y = length)) +
    geom_boxplot(aes(fill = mouse))
# ewentualnie:
# bwplot(length~mouse, data=tabelka, ylab="pitu to pitu")

# dla kazdego typu leczenia widaÄ‡ ew. rÃ³Å¼nice
# w dÅ‚ugoÅ›ci spajnÃ³w miÄ™dzy rodzajami myszy
dlSPajnowPerleczeniaROzrozniajacTypyMysz <- ggplot(data = tabelka, aes(x = treatment, y = length)) +
    geom_boxplot(aes(fill = mouse))

# dla kaÅ¼dego typu myszy widaÄ‡ rÃ³Å¼nice miÄ™dzy dÅ‚ugoÅ›ciami spajnÃ³w
# dla rÃ³Å¼nych leczeÅ„
dlSpajnowPerTypMyszyROzrozniajacLeczenie <- ggplot(data = tabelka, aes(x = mouse, y = length)) +
    geom_boxplot(aes(fill = treatment))



# Warto popatrzeÄ‡:

# np. lit daje najkrÃ³tsze spajny
dlugoscSpajnowPerLeczenie

# np. KO maja wyrozniajace sie dlugosc (bardziej krÃ³tkoÅ›Ä‡) spajnÃ³w
dlugoscSpajnowPerTypMyszy

# na nastÄ™pnych dwÃ³ch rysunkach widaÄ‡, Å¼e nie kaÅ¼dy typ myszy byÅ‚ poddawany kaÅ¼demu leczeniu
dlSpajnowPerTypMyszyROzrozniajacLeczenie
dlSPajnowPerleczeniaROzrozniajacTypyMysz



# w fazie pierwszej mieliÅ›my obczaiÄ‡ interakcjÄ™
# typu myszki z typem 'leczenia' jakiemu zostaÅ‚ poddany
# wycinek z jej mÃ³zgu

# WeÅºmy na poczÄ…tek mouse i treatment jako efekty staÅ‚e
# a rodzaj myszki jako efekt losowy
modelM <- lmer(length ~ mouse +
    treatment + treatment:mouse +
    (1|Animal), data=tabelka)

summary(modelM)


# czy cokolwiek z tego wynika, to ja nie wiem...
ranefM = ranef(modelM, condVar =TRUE)
dotplot(ranefM)





# Moje wypociny w formie data.table - podobno fajny pomysÅ‚ bo data.table ma dziaÅ‚aÄ‡ duÅ¼o szybciej niÅ¼ data.frame [ZGADZAM SIÊ]
# DTabelka <- data.table(as.integer(dendriticSpines[,1]),dendriticSpines[,2],dendriticSpines[,3],dendriticSpines[,4],dendriticSpines[,5],dendriticSpines[,6],dendriticSpines[,7])
# sapply(DTabelka, class)
# names(DTabelka) <- names(dendriticSpines)
# dim(DTabelka)
# tables()
# setkey(DTabelka, "Animal")
# summary(DTabelka)

# DTabelka[Animal==3,]
# DTabelka[Photo_ID_abs==3,]
# DTabelka[spine_number==3,]
# tabelka[,summary(lm(length~mouse+treatment+mouse:treatment))]
# tabelka[,lmer(length~mouse+treatment+(1|spine_number))]


#####################################################################################
spines <- data.table(dendriticSpines)

##Wybieramy study
spines[, .N, by = Study]
selectedStudy <- "ko"
spines <- filter(spines, Study == selectedStudy)
list <- split(spines$mouse, spines$treatment)

#W ka¿dym study analizowane s¹ tylko dwa rodzaje treatment oraz dwa typy myszy. 
#W "ko" jest to odpowiednio: brak treatment, li oraz KO, WT. Pozosta³e poziomy obu zmiennych usuwamy.
sapply(list, summary)
spines$mouse <- factor(spines$mouse)
spines$treatment <- factor(spines$treatment)
spines$Photo_ID_abs <- factor(spines$Photo_ID_abs)
spines$spine_number <- factor(spines$spine_number)

#przyjrzyjmy siê dok³adniej liczbie spajnów na poszczególnych zdjêciach - czy jest zale¿noœæ miêdzy gêstoœci¹ sieci
#spajnów a d³ugoœci¹? [nie jestem przekonana, czy tu coœ wykryjemy...]
spines[, "Animal:Photo" := paste(Animal, Photo_ID_abs, sep = ":")]
list <- split(spines$spine_number, spines$`Animal:Photo`)
sapply(list, max)
spines[, noOfSpines := max(spine_number), by = 'Animal:Photo']

#Szukamy interakcji
aggregate(length ~ mouse + treatment, data = spines, FUN = "mean")
interaction.plot(spines$mouse, spines$treatment, spines$length)
#Mo¿emy siê wiêc spodziewaæ, ¿e WT w po³¹czeniu z brakiem treatment daje d³u¿sze spajny.

#Budujemy model.
model <- lmer(length ~ treatment*mouse + (1|Animal:Photo_ID_abs), data = spines)
summary(model) #trzeba przekszta³ciæ wartoœci t na p-value

#Budujemy model, dodaj¹c liczbê spajnów
model2 <- lmer(length ~ treatment*mouse + (1|Animal), data = spines)
summary(model2)


#Który model lepszy?
anova(model, model2) #mo¿emy zostaæ przy pierwszym

model3 <- lmer(length ~ treatment*mouse + (1|Animal:Photo_ID_abs), data = spines)
summary(model3)

anova(model2, model3)


#DO ZROBIENIA:

#Diagnostyka
      ##Czy epsilon ma rozk³ad normalny?
      ##Czy u ma rozk³ad normalny?
      ##Czy wszystkie zmienne s¹ istotne? - testy permutacyjne
      ##Obrazki

      