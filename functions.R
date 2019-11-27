ind_fun = function(train_sub, classifier){
  indmat = matrix(-1, ncol(train_sub), nrow(classifier$TSPs))
  for(i in 1:nrow(classifier$TSPs)){
    p1 = which(rownames(train_sub) == classifier$TSPs[i,1])
    p2 = which(rownames(train_sub) == classifier$TSPs[i,2])
    if(length(p1) == 0) stop(sprintf("%s is not found in input matrix rownames",classifier$TSPs[i,1]))
    if(length(p2) == 0) stop(sprintf("%s is not found in input matrix rownames",classifier$TSPs[i,2]))
    indmat[,i] = (train_sub[p1,] > train_sub[p2,])^2
  }
  indmat = t(indmat)
  colnames(indmat) = colnames(train_sub)
  return(indmat)
}

apply_classifier = function(data, classifier){
  
  # drop TSPs with 0 weight
  classifier$TSPs = classifier$TSPs[classifier$fit$beta[-1]!=0,]
  
  # create TSP indicator matrix
  indmat = t(ind_fun(train_sub = data, classifier = classifier))
  
  # name columns
  colnames(indmat) = paste("indmat", 1:ncol(indmat), sep = "")
  
  # add intercept column
  X=cbind(rep(1, nrow(indmat)), indmat)
  
  # make prediction 
  beta = classifier$fit$beta
  beta = beta[beta!=0]
  Pred_prob_basal = exp(X%*%beta)/(1+exp(X%*%beta))
  
  # get subtype
  Subtype = c("classical","basal-like")[(Pred_prob_basal > 0.5)^2 + 1]
  
  # get graded subtype
  Subtype_graded = rep(1, length(Pred_prob_basal))
  Subtype_graded[Pred_prob_basal < .1] = 1
  Subtype_graded[Pred_prob_basal > .1 & Pred_prob_basal < .4] = 2
  Subtype_graded[Pred_prob_basal > .4 & Pred_prob_basal < .5] = 3
  Subtype_graded[Pred_prob_basal > .5 & Pred_prob_basal < .6] = 4
  Subtype_graded[Pred_prob_basal > .6 & Pred_prob_basal < .9] = 5
  Subtype_graded[Pred_prob_basal > .9 ] = 6
  
  # graded categories
  grades = c("strong classical","likely classical","lean classical","lean basal-like","likely basal-like", "strong basal-like")
  Subtype_graded = grades[Subtype_graded]
  
  # final matrix
  final = data.frame(Pred_prob_basal= Pred_prob_basal, Subtype = Subtype, Subtype_graded = Subtype_graded)
  rownames(final) = colnames(data)
  
  return(final)
}

