---
output:
  html_document: default
  pdf_document: default
---
# PurIST

Here we provide an example dataset and walkthrough to performing predictions in R.  You can jump to the end of the document to copy the whole code block needed to run this example. 

# Walkthrough
First load the purist classifier object.

```R
# load object
load("fitteds_public_2019-02-12.Rdata")

# Extract classifier 
classifier = classifs[[1]]
```

Here is the list of classifier genes, where each row pertains to a gene pair.  

```R
# get list of gene pairs
TSPlist = classifier$TSPs[classifier$fit$beta[-1]!=0,]

```

Printing this list will give you the following

```R
GPR87	REG4
KRT6A	ANXA10
BCAR3	GATA6
PTGES	CLDN18
ITGA3	LGALS4
C16orf74	DDC
S100A2	SLC40A1
KRT5	CLRN3
```

Now we get our example data matrix.  This data matrix should the following

1.  Rows as the genes, each row will be labeled with the gene name. 
2.  Columns as samples, with each column labeled with the sample name.  

This data matrix should contain all of the genes in the list above.  

### IMPORTANT NOTE FOR MICROARRAYS  

For Microarray expression data, we urge some caution in use given that relative probe expression between genes is not always proportion to the relative biological expression given probe effects.   In the past we simply average across probes belonging to the same gene prior to use in the classifier.  For those reasons we recommend RNA-seq or nanostring for classifier use, however we have seen good performance in prior microarray datasets. 

### IMPORTANT NOTE FOR RNA-seq  

If using RNA-seq data, using TPM (transcripts per million) measurements is necessary to compare relative expression per gene.  If not available, FPKM (fragments per kilobase per million) data is sufficient.  Both these measurements are available from common expression quantitation pipelines such as Salmon. Do not use raw counts or expected read counts.  

### IMPORTANT NOTE FOR NANOSTRING  

For nanostring data, we have found that utilizing the usual raw transcript counts provided from common software is sufficient for use. 


In general, between-sample normalization is not necessary for our method, as we utilize a rank based approach to generate the predictors for our prediction model.  

## Load data and apply classifier

Now lets load the example data matrix. 

```R
# load the data, objected named 'dat'
load("example.Rdata")
```

Now we can applied the classifier to the data.  We will source the helper functions to facilitate this process first.  Then we apply the predictive model.  

```R
# source functions
source("functions.R")

# apply classifier
predictions = apply_classifier(data = dat, classifier = classifier)
```

## Interpreting output 

The predictions object above contains a n by 3 data frame, where the 1st column is the predicted probability of each sample  of belonging to the "basal-like" subtype.  The second column is the subtype call based on a predicted probability cutoff of 0.5.  Greater than 0.5 indicates the basal-like subtype, and less than 0.5 indicated the classical subtype.  The third column is a graded subtype call similar to the PurIST manuscript, indicating the confidence of the call (Strong, Likely, Lean).  We have preliminary evidence that the strength of the call may actually reflect the underlying mixture of basal and classical cells in the tumor itself.  

The output generated from our example data is given below ('predictions' object).  


```R
          Pred_prob_basal    Subtype     Subtype_graded
Sample_1      0.936765062 basal-like Likely  Basal-like
Sample_2      0.991222760 basal-like Likely  Basal-like
Sample_3      0.002768882  classical   Strong Classical
Sample_4      0.991222760 basal-like Likely  Basal-like
Sample_5      0.092112770  classical   Strong Classical
Sample_6      0.019727002  classical   Strong Classical
Sample_7      0.001095705  classical   Strong Classical
Sample_8      0.205301579  classical  Likely  Classical
Sample_9      0.205301579  classical  Likely  Classical
Sample_10     0.991222760 basal-like Likely  Basal-like
```

# Summary

Putting it all together, once can use the following set of commands in R to generate the above

```R
# load data objects and source functions
load("fitteds_public_2019-02-12.Rdata")
load("example.Rdata")
source("functions.R")

# Extract classifier 
classifier = classifs[[1]]


# apply classifier 
predictions = apply_classifier(data = dat, classifier = classifier)
```
