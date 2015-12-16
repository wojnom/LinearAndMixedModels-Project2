---
title: "Project 2"
author: "Durszlaczek i przyjaciele"
date: "Modele liniowe i mieszane"
output: 
  html_document:
    toc: TRUE
---
### 1. Introduction - study description and overview

##### Study : KO

```r
selectedStudy <- "ko"
spines <- spines[Study==selectedStudy,]

lengthPerTreatment <- ggplot(data = spines, aes(x = treatment, y = length)) + geom_boxplot(aes(fill = treatment))
lengthPerMouseType <- ggplot(data = spines, aes(x = mouse, y = length))+geom_boxplot(aes(fill = mouse))

grid.arrange(lengthPerTreatment,lengthPerMouseType, ncol = 2)
```

<img src="prezentacja_files/figure-html/unnamed-chunk-2-1.png" title="" alt="" width="672" />

```r
(lengthPerMouseDifferentiatedByTreatment <- ggplot(data = spines, aes(x = mouse, y = length)) + geom_boxplot(aes(fill = treatment)))
```

<img src="prezentacja_files/figure-html/unnamed-chunk-2-2.png" title="" alt="" width="672" />

### 2. Hypothesis
##### Interaction between mouse type and treatment
We may see significantly different means between different combinations of mouse and treatment

```
##    treatment        KO        WT
## 1:         - 0.3880219 0.4819959
## 2:        li 0.3632416 0.3745729
```


```r
interaction.plot(spines$mouse, spines$treatment, spines$length)
```

<img src="prezentacja_files/figure-html/unnamed-chunk-4-1.png" title="" alt="" width="672" />

### 3. How we got there?
#### Maybe number of spines on the photo means something?

As we may observe, it doesn't really matter

```r
spines[, noOfSpines := max(spine_number), by = 'Animal:Photo']
model <- lmer(length ~ treatment*mouse + (1|Animal) + (1|Photo_ID_abs), data = spines)
modelWithNumberOfSpines <- lmer(length ~ treatment*mouse + (1|Animal) + (1|Photo_ID_abs) + (1|noOfSpines), data = spines)
anova(model, modelWithNumberOfSpines)
```

```
## Data: spines
## Models:
## model: length ~ treatment * mouse + (1 | Animal) + (1 | Photo_ID_abs)
## modelWithNumberOfSpines: length ~ treatment * mouse + (1 | Animal) + (1 | Photo_ID_abs) + 
## modelWithNumberOfSpines:     (1 | noOfSpines)
##                         Df     AIC     BIC logLik deviance Chisq Chi Df
## model                    7 -2829.3 -2781.8 1421.7  -2843.3             
## modelWithNumberOfSpines  8 -2827.3 -2773.1 1421.7  -2843.3 2e-04      1
##                         Pr(>Chisq)
## model                             
## modelWithNumberOfSpines     0.9892
```
#### Fixed effect shall be mouse and treatment
It is pretty straightforward from a logical point of view. Finding mouse type and treatment of a particular mouse is obvious (so it's cheap) and there is comparatively small number of possible levels

#### Random effects shall be Animal and Photo
Effect of a single animal is random - every study and every year animals are just different individuals. After a quick look at the data we may see that number of photos per animal is irregular. Interestingly, for our study (i.e. KO) there is no such case that particular photo number occurs for two (or more) different animals.

#### Why Photo should be considered as nested in Animal?
Despite the fact it shouldn't matter in our study (as stated just before) it is reasonable (and confirmed by simulations) to look at photos as 'effects of single animal'.

#### So the model will be length ~ treatment + mouse + (1|Animal/Photo)

#### Diagnostyka - Michal cisnie!


### 4. Conclusions - Michal, jakbys mogl to na koniec jakos skomponowac...



### 5. Literature
#### [1] Modele liniowe z efektami stałymi, losowymi i mieszanymi. P. Biecek

#### [2] www.google.com
