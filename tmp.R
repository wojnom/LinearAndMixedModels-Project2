As stated above, we made the following mixed model
```{r, warning=FALSE, message=FALSE}
modelZagniezdzony <- lmer(length ~ mouse * treatment+ (1|Animal/Photo_ID_abs), data = spines)
qqnorm(residuals(modelZagniezdzony),pch=1)
```
Unfortunately the assumptions of mixed models are not met, bacause residuals don't have normal distribution. Looking at tail of this qqplot we guessed, that taking the logarithm of our dependant variable might be helpful. 
```{r, warning=FALSE, message=FALSE,echo=FALSE}
#logtrans
model_list <- list(21)
for(i in 0:20){
model_list[[i+1]] <- lmer(log(length-0.1+i*0.01) ~ treatment*mouse + (1|Animal/Photo_ID_abs), 
data = spines)
}
par(mfrow = c(4,5))
for (i in 1:20){
new_model <- model_list[[i]]
qqnorm(residuals(new_model),pch=16)
qqline(residuals(new_model))
}
#BoxCox
BC <- function(y,lambda=1){
if(lambda !=0){
(y^lambda-1)/lambda
}else{
log(y)
}
}

model_list_2 <- list(21)
for(i in 0:20){
model_list_2[[i+1]] <- lmer(BC(spines$length,-2+i*0.2) ~ treatment*mouse + (1|Animal/Photo_ID_abs), data = spines)
}

par(mfrow=c(4,5))
for (i in 1:20){
new_model <- model_list_2[[i]]
qqnorm(residuals(new_model),pch=16)
qqline(residuals(new_model))
}
```
We checked qqplots of many different models in logtrans and BoxCox class. After that we decided, that our model will be 
```{r, warning=FALSE, message=FALSE}
superModel <- lmer(log(length-0.04) ~ treatment*mouse + (1|Animal/Photo_ID_abs), 
data = spines)
par(mfrow = c(1,1))
qqnorm(residuals(superModel))
qqline(residuals(superModel))
```
Now we can assume, that the residuals follow the normal distribution. Another assumption is that u is normally distributed too. Let's see whether it's false or not.
```{r, warning=FALSE, message=FALSE}
library(lattice)
u=ranef(superModel,postVar=T)
dotplot(u)
qqmath(u)$`Animal:Photo_ID_abs`
```
```{r, warning=FALSE, message=FALSE,echo=FALSE}

#Czy animal:photo jest istotn¹ zmienn¹

for(i in 0:20){
model_list[[i+1]] <- lmer(log(length-0.1+i*0.01) ~ treatment*mouse + (1|Animal), 
data = spines)
}
par(mfrow = c(4,5))
for (i in 1:20){
new_model <- model_list[[i]]
qqnorm(residuals(new_model),pch=16)
qqline(residuals(new_model))
}

superModel2 <- lmer(log(length-0.04) ~ treatment*mouse + (1|Animal), 
data = spines)

anova(superModel2, superModel)

N <- 1000
logs <- replicate(N, logLik(lmer(log(length-0.03) ~ 
treatment + mouse + sample(treatment:mouse) + (1|Animal/Photo_ID_abs), data = spines)))
mean(logs) > logLik(superModel)
```
