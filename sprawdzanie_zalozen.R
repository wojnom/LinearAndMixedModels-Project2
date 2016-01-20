library(lme4)
library(MASS)
library(lattice)
library(ggplot2)
library(nortest)

### szukanie najlepszego modelu
model <- lmer(log(length)~mouse*treatment+(1|Study:Animal:Photo_ID_abs)+(1|Study:Animal),data=dendriticSpines,REML=F)
summary(model)
### normalnosc reszt
qqnorm(residuals(model))
qqline(residuals(model),col="red")
lillie.test(residuals(model))

### normalnosc efektow losowych
### StudyAnimalPhoto jest normalny
StudyAnimalPhoto <- unlist(ranef(model,condVar=T)$`Study:Animal:Photo_ID_abs`)
qqnorm(StudyAnimalPhoto)
qqline(StudyAnimalPhoto,col="red")
shapiro.test(StudyAnimalPhoto)

#StudyAnimal - qqplot slaby, shapiro-wilk slaby, ale probka mala i przez qqmath mozna
#na styk poprowadzic prosta,wiec nie odrzucamy zalozenia o normalnosci
StudyAnimal <- unlist(ranef(model,condVar=T)$`Study:Animal`)
qqnorm(StudyAnimal)
qqline(StudyAnimal,col="red")
shapiro.test(StudyAnimal)
qqmath(ranef(model,condVar=T))$`Study:Animal`

### niezaleznosc reszt od wyestymowanych length
u <- ranef(model, condVar = TRUE)
e <- residuals(model)

w <- u$`Study:Animal`[paste0(dendriticSpines$Study,":",dendriticSpines$Animal),1]

x <- u$`Study:Animal:Photo_ID_abs`[paste0(dendriticSpines$Study,":",dendriticSpines$Animal,":",dendriticSpines$Photo_ID_abs),1]

d <- data.frame(model_residuals=c(e,e), random_effect=c(w,x),
                type=rep(c("Study:Animal", "Study:Animal:Photo_ID_abs"), each=nrow(dendriticSpines)))
ggplot(d, aes(x=random_effect, y=model_residuals)) + geom_point() + geom_smooth(method="lm", col="red", size=1)+
      facet_wrap(~type)

### jednorodnosc wariancji
by(residuals(model),dendriticSpines$mouse : dendriticSpines$treatment,var)

### Wald test for fixed effects - li oraz chiron sa niestotne
tStat <- summary(model)$coeff[,3]
pValues <- sapply(1:length(tStat),function(i) {2*pnorm(abs(tStat[i]),lower.tail = F)})
pValues

### istotnosc efektow losowych

### testy permutacyjne - kazdy robi sie u mnie ok 6min
#Aby sprawdzic, czy Study:Animal:Photo jest istotne przemieszam photo i zobacze, czy dostaje dobre wyniki
pocz <- proc.time()
N <- 100
dS <- dendriticSpines
logs <- replicate(N, {
      dS$Photo_ID_abs <- sample(dS$Photo_ID_abs)
      logLik(lmer(log(length)~mouse*treatment+(1|Study:Animal:Photo_ID_abs)+(1|Study:Animal),data=dS,REML=F))
}
      )
mean(logs > logLik(model))
proc.time()-pocz
#Wyszlo 0, wiec photo jest istotne

pocz <- proc.time()
N <- 100
dS <- dendriticSpines
logs <- replicate(N, {
      dS$Animal <- sample(dS$Animal)
      logLik(lmer(log(length)~mouse*treatment+(1|Study:Animal:Photo_ID_abs)+(1|Study:Animal),data=dS,REML=F))
}
)
mean(logs > logLik(model))
proc.time()-pocz
#Animal tez jest istotne

## Anova
modelBezPhoto <- lmer(log(length)~mouse*treatment+(1|Study:Animal),data=dendriticSpines,REML=F)
modelBezAnimal <- model <- lmer(log(length)~mouse*treatment+(1|Study:Animal:Photo_ID_abs),data=dendriticSpines,REML=F)

anova(modelBezPhoto,model)
anova(modelBezAnimal,model)
