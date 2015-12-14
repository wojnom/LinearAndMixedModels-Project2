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


######################################################################

### Z ANOVY wynika, ze zostajemy przy modelu z Animal:Photo

#Czy reszty maja rozklad normalny?
qqnorm(residuals(model),pch=16) #ZDECYDOWANIE NIE
qqnorm(residuals(model2),pch=16) #TEN MODEL TEZ NIE JEST LEPSZY
qqnorm(residuals(model3),pch=16) #TU TAKZE TRAGEDIA
#Te reszty wyraznie rosna, wiec dla duzych liczb jest odchylenie od rozkladu normalnego.
#Wydaje mi sie ze logarytmowanie powinno pomoc.

#Przeksztalcam dane:
hist(spines$length)
range(spines$length)

#Funkcja logtransform dziala dla modeli liniowych, ale jak wpisywalem model mieszany,to
#dostawalem bledy. Szukalem chwile w necie jak to poprawic, ale nie znalazlem.
#Obejrzalem wiec pare qqplotow, zeby na oko dobrac dobra transformacje danych

model4 <- lmer(log(length) ~ treatment*mouse + (1|Animal:Photo_ID_abs), data = spines)
qqnorm(residuals(model4),pch=16)

#Jaka jest najlepsza transformacja w klasie logtrans?
model_list <- list(21)
for(i in 0:20){
      model_list[[i+1]] <- lmer(log(length-0.1+i*0.01) ~ treatment*mouse + (1|Animal:Photo_ID_abs), 
                                data = spines)
}

#na moje oko najlepszy model to log(length-0.04), czyli model_list[[6]]
par(mfrow=c(4,5))
for (i in 1:20){
      new_model <- model_list[[i]]
      qqnorm(residuals(new_model),pch=16)
      qqline(residuals(new_model))
}

# Jak sprawdzic to nie na oko? Przy pomocy wiarygodnosci
LLH <- sapply(model_list,logLik)
which.max(LLH)
LLH
#O dziwo zwraca to inne wyniki ni¿ wynik na oko
#Tutaj jest porównanie najlepszego wykresu na moje oko i tego z najlepsza LLH
par(mfrow=c(1,2))
qqnorm(residuals(model_list[[7]]),pch=16)
qqline(residuals(model_list[[7]]))
qqnorm(residuals(model_list[[20]]),pch=16)
qqline(residuals(model_list[[20]]))

#Jaka transformacja jest najlepsza w klasie BoxCox?

BC <- function(y,lambda=1){
      if(lambda !=0){
            (y^lambda-1)/lambda
      }else{
            log(y)
      }
}

model_list_2 <- list(21)
for(i in 0:20){
      model_list_2[[i+1]] <- lmer(BC(spines$length,-2+i*0.2) ~ treatment*mouse + (1|Animal:Photo_ID_abs), data = spines)
}

par(mfrow=c(4,5))
for (i in 1:20){
      new_model <- model_list_2[[i]]
      qqnorm(residuals(new_model),pch=16)
      qqline(residuals(new_model))
}

#sensowne rysunki sa dla 10 i 11 modelu, tzn. dla logarytmu i 5(y^0.2-1)
logLik(model_list_2[[10]])
logLik(model_list_2[[11]])

#Porownanie najlepszego modelu z BoxCox z najlepszym logtrans
#Tytul wykresu to loglikelihood
par(mfrow=c(1,2))
best_logtrans <- model_list[[7]]
qqnorm(residuals(best_logtrans),pch=16,main=round(logLik(best_logtrans)))
qqline(residuals(best_logtrans))
best_BC <- model_list_2[[11]]
qqnorm(residuals(best_BC),pch=16,,main=round(logLik(best_BC)))
qqline(residuals(best_BC))
#Trudno mi powiedziec na który model mamy sie zdecydowac
#Ja bym wybral chyba ten lewy wykres. 

best_model <- best_logtrans
logLik(best_model)
summary(best_model)

library(lattice)
#Czy u ma rozklad normalny?
u=ranef(best_model,postVar=T)
dotplot(u)
#Wyraznie odstaja skrajne grupy :/ Moim zdaniem to nie jest raczej rozklad normalny

#Istotnosc czynnikow stalych
tStat <- summary(best_model)$coeff[,3]
pValues <- sapply(1:length(tStat),function(i) {2*pnorm(abs(tStat[i]),lower.tail = F)})
pValues
#Z testu Walda wynika, ze mouse WT i interakcja sa na pewno istotne, a treatment tylko na 
#poziomie 5%

#UWAGA : W labach kazdy taki test(1000 powtorzen) robil sie ok. 2 minut

#Test permutacyjny sprawdzajacy czy rodzaj myszy jest istotny
N <- 1000
logs <- replicate(N, logLik(lmer(log(length-0.04) ~ 
                                       treatment*sample(mouse) + (1|Animal:Photo_ID_abs), data = spines)))
mean(logs>logLik(best_model)) 
# mi wysz³o,ze srednia to 0,wiec rodzaj myszy jest istotny

#Test permutacyjny sprawdzajacy czy sposob leczenia jest istotny
N <- 1000
logs <- replicate(N, logLik(lmer(log(length-0.04) ~ 
                                       sample(treatment)*mouse + (1|Animal:Photo_ID_abs), data = spines)))
mean(logs>logLik(best_model))
#Tutaj te¿ mean =0 

#Wyniki testow permutacyjnych zgadzaja sie z testem Walda, wiec jest dobrze.

#Test permutacyjny sprawdzajaczy czy komponent wariacyjny jest istotny
spinesPermuted <- spines
N <- 1000
logs <- replicate(N, {
      spinesPermuted$`Animal:Photo` <- sample(spinesPermuted$`Animal:Photo`)
      logLik(lmer(log(length-0.04) ~ treatment*mouse + (1|`Animal:Photo`), data = spinesPermuted))
}
)
mean(logs>logLik(best_model))
#znow srednia wyszla mi 0, czyli komponent wariacyjny jest istotny

#cos za dobre te wyniki...
#Widzicie gdzies blad?



#DO ZROBIENIA:

##Obrazki

      