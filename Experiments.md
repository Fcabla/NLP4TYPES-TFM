Experiments:
 
5-Fold evaluation results (original) (abs, ne)

| Resources | Acc   | hPrec | hRec  | hF    |
|-----------|-------|-------|-------|-------|
| 10k       | 0.734 | 0.894 | 0.886 | 0.890 |
| 1M        | 0.825 | 0.944 | 0.939 | 0.942 |
| Full(3M)  | 0.835 | 0.952 | 0.949 | 0.950 |

5-Fold evaluation results (reproduced) (abs, ne)

| Resources | Acc   | hPrec | hRec  | hF    |
|-----------|-------|-------|-------|-------|
| 10k       | 0.766 | 0.899 | 0.898 | 0.899 |
| 1M        | 0.880 | 0.956 | 0.959 | 0.957 |
| Full(3M)  | 0.879 | 0.954 | 0.956 | 0.955 |
------

5-Fold 1M entries (original) abstracts, name entity recognition, preprocessing

| ABS | NER | PP | Acc   | hPrec | hRec  | hF    |
|-----|-----|----|-------|-------|-------|-------|
| +   | +   | -  | 0.825 | 0.944 | 0.939 | 0.942 |
| +   | +   | +  | 0.811 | 0.937 | 0.932 | 0.935 |
| +   | -   | -  | 0.790 | 0.937 | 0.930 | 0.933 |
| +   | -   | +  | 0.779 | 0.929 | 0.921 | 0.925 |
| -   | +   | -  | 0.568 | 0.782 | 0.782 | 0.782 |

5-Fold 1M entries (reproduced) abstracts, name entity recognition, preprocessing

| ABS | NER | PP | Acc   | hPrec | hRec  | hF    |
|-----|-----|----|-------|-------|-------|-------|
| +   | +   | -  | 0.880 | 0.956 | 0.959 | 0.957 |
| +   | +   | +  | 0.837 | 0.935 | 0.936 | 0.935 |
| +   | -   | -  | 0.852 | 0.949 | 0.950 | 0.949 |
| +   | -   | +  | 0.813 | 0.926 | 0.928 | 0.927 |
| -   | +   | -  | 0.575 | 0.783 | 0.779 | 0.781 |

------

Gold standard evaluation (original)
1825 entries
| Resources | Acc   | hPrec | hRec  | hF    |
|-----------|-------|-------|-------|-------|
| 10k       | 0.205 | 0.669 | 0.624 | 0.645 |
| 1M        | 0.420 | 0.811 | 0.807 | 0.809 |
| Full(3M)  | 0.449 | 0.827 | 0.822 | 0.825 |
|-----------|-------|-------|-------|-------|
| hSVM      | 0.548 | 0.890 | 0.665 | 0.761 |
| SDType    | 0.338 | 0.809 | 0.641 | 0.715 |

Gold standard evaluation (reproduced)
1289 entries 
| Resources | Acc   | hPrec | hRec  | hF    |
|-----------|-------|-------|-------|-------|
| 10k       | 0.479 | 0.830 | 0.815 | 0.823 |
| 1M        | 0.556 | 0.874 | 0.872 | 0.873 |
| Full(3M)  | 0.573 | 0.889 | 0.883 | 0.886 |
|-----------|-------|-------|-------|-------|
| hSVM      | 0.548 | 0.890 | 0.665 | 0.761 |
| SDType    | 0.338 | 0.809 | 0.641 | 0.715 |

New gold standard eval
2563962 entries
10k: 0.639 0.855 0.893 0.874 
1m: 0.653 0.875 0.926 0.900 
3m: 0.667 0.883 0.934 0.908

------

Testing of new possible upgrades with 1Million instances:
	- printable names = SoccerPlayer -> Soccer Player
	- path2root = SoccerPlayer -> owl:Thing, Agent, Person, Athlete, SoccerPlayer


| printable names | path2root | Acc   | hPrec | hRec  | hF    |
|-----------------|-----------|-------|-------|-------|-------|
| -               | -         | 0.880 | 0.956 | 0.959 | 0.957 |
| +               | -         | 0.873 | 0.955 | 0.955 | 0.955 |
| -               | +         | 0.879 | 0.957 | 0.959 | 0.958 |
| +               | +         | 0.869 | 0.953 | 0.956 | 0.955 |


------
Experiment with 1 million records, how preprocessing techniques affect the result?

| stw | stemm | lemma | punct | Acc   | hPrec | hRec  | hF    |
|-----|-------|-------|-------|-------|-------|-------|-------|
| -   | -     | -     | -     | 0.880 | 0.956 | 0.959 | 0.958 |
| +   | -     | -     | -     | 0.733 | 0.890 | 0.892 | 0.891 |
| +   | +     | -     | -     | 0.727 | 0.883 | 0.882 | 0.883 |
| +   | -     | +     | -     | 0.599 | 0.815 | 0.817 | 0.816 |
| +   | +     | +     | -     | 0.609 | 0.817 | 0.820 | 0.818 |
| +   | -     | -     | +     | 0.728 | 0.883 | 0.886 | 0.885 |

------

Test with spanish data:
There are in total 785750 instances, we are going to try with the 100%, 33% (259297) and 0.33% of the total data (like english).

5-Fold evaluation results (reproduced) (abs, ne)

| Resources | Acc   | hPrec | hRec  | hF    |
|-----------|-------|-------|-------|-------|
| 0.33      | 0.792 | 0.896 | 0.917 | 0.906 |
| 33        | 0.921 | 0.972 | 0.974 | 0.973 |
| Full(800k)| 0.924 | 0.973 | 0.976 | 0.974 |

5-Fold 33% entries (original) abstracts, name entity recognition, preprocessing

| ABS | NER | PP | Acc   | hPrec | hRec  | hF    |
|-----|-----|----|-------|-------|-------|-------|
| +   | +   | -  | 0.921 | 0.972 | 0.974 | 0.973 |
| +   | +   | +  | 0.903 | 0.963 | 0.965 | 0.964 |
| +   | -   | -  | 0.899 | 0.968 | 0.970 | 0.969 |
| +   | -   | +  | 0.876 | 0.956 | 0.958 | 0.957 |
| -   | +   | -  | 0.650 | 0.796 | 0.801 | 0.799 |


| printable names | path2root | Acc   | hPrec | hRec  | hF    |
|-----------------|-----------|-------|-------|-------|-------|
| -               | -         | 0.921 | 0.972 | 0.974 | 0.973 |
| +               | -         | 0.917 | 0.972 | 0.973 | 0.972 |
| -               | +         | 0.920 | 0.972 | 0.974 | 0.973 |
| +               | +         | 0.915 | 0.971 | 0.973 | 0.972 |

There is no gold standard dataset in Spanish so there is no testing with that.

------

(146 unique classes on the spanish dbpedia dataset vs 405 unique classes on the english dbpedia dataset)
Despite having less data, the Spanish version performs better than the English version. It is believed that this is due to the number of possible classes in both datasets.

------

5-Fold evaluation results (reproduced) (abs, ne)

| Resources | Acc   | hPrec | hRec  | hF    |
|-----------|-------|-------|-------|-------|
| 10k       | 0.766 | 0.899 | 0.898 | 0.899 |
| 1M        | 0.880 | 0.956 | 0.959 | 0.957 |
| Full(3M)  | 0.xxx | 0.xxx | 0.xxx | 0.xxx |

10k: 0.777 0.912 0.918 0.915 

5-Fold evaluation results (reproduced) (abs, ne) (cropping the tdm)

| Resources | Acc   | hPrec | hRec  | hF    |
|-----------|-------|-------|-------|-------|
| 10k       | 0.777 | 0.904 | 0.908 | 0.906 |
| 1M        | 0.876 | 0.955 | 0.955 | 0.955 |
| Full(3M)  | 0.875 | 0.951 | 0.954 | 0.952 |

1m: 1715230 --> 594896 features

-------
5-Fold evaluation results (reproduced) (abs, ne) (2-grams)

| Resources | Acc   | hPrec | hRec  | hF    |
|-----------|-------|-------|-------|-------|
| 10k       | 0.768 | 0.911 | 0.903 | 0.907 |
| 1M        | 0.xxx | 0.xxx | 0.xxx | 0.xxx |
| Full(3M)  | 0.xxx | 0.xxx | 0.xxx | 0.xxx |

-------
5-Fold evaluation results (reproduced) (abs, ne) (3-grams)

| Resources | Acc   | hPrec | hRec  | hF    |
|-----------|-------|-------|-------|-------|
| 10k       | 0.739 | 0.881 | 0.877 | 0.879 |
| 1M        | 0.xxx | 0.xxx | 0.xxx | 0.xxx |
| Full(3M)  | 0.xxx | 0.xxx | 0.xxx | 0.xxx |

-------------
learning curve:
		acc    hP    hR    hF 
0.5:	0.879 0.956 0.959 0.957 
1:		0.879 0.956 0.959 0.957
1.5:	0.882 0.957 0.958 0.958 
2:		0.881 0.957 0.958 0.957 
2.5:	0.880 0.955 0.957 0.956 
3:

-------------
trim:
baseline: 	
doc freq 2 : 
term freq 2: 0.877 0.954 0.955 0.955 
term freq 5: 0.867 0.949 0.951 0.950 

| min_term | max_doc | Features | Acc   | hPrec | hRec  | hF    |
|----------|---------|----------|-------|-------|-------|-------|
| 0.95     | 0.1     | 86929    | 0.857 | 0.943 | 0.945 | 0.944 | 
| 0.90     | 0.1     | 186195   | 0.864 | 0.947 | 0.949 | 0.948 | 
| 0.90     | 0.1     | 366712   | 0.870 | 0.950 | 0.952 | 0.951 | 
| 0.95     | 0.2     | 86929    | 0.857 | 0.943 | 0.945 | 0.944 |
| 0.90     | 0.2     | 186195   | 0.864 | 0.947 | 0.949 | 0.948 | 
| 0.80     | 0.2     | 366712   | 0.870 | 0.950 | 0.952 | 0.951 |
| 0.95     | 0.3     | 86929    | 0.857 | 0.943 | 0.945 | 0.944 |
| 0.90     | 0.3     | 186195   | 0.864 | 0.947 | 0.949 | 0.948 |
| 0.80     | 0.3     | 366712   | 0.870 | 0.950 | 0.952 | 0.951 | 
| xxxx     | xxx     | 1716880  | 0.879 | 0.956 | 0.959 | 0.957 | 
------------
fasttext
1m 200 epchs

N	201230
P@1	0.898
R@1	0.898

3m 100 epchs
N	609788
P@1	0.885
R@1	0.885

original ne_types
>>> df["max"].value_counts()
False    1532048
True     1516894
Name: max, dtype: int64
>>> 1516894/3048942
0.49751487565194746

no ne_types
>>> df["max"].value_counts()
False    2179510
True      854196
Name: max, dtype: int64
>>> 854196/3033706
0.2815684842235866

unique ne_types
>>> df["max"].value_counts()
False    1881317
True     1152389
Name: max, dtype: int64
>>> 1152389/3033706
0.3798617928039171

1M,en,ABS+NE+use_lower=FALSE "2022-02-11 09:09:46 CET"
  acc    hP    hR    hF 
0.917 0.975 0.974 0.975 

1M,en,ABS+NE+use_lower=TRUE 2022-02-11 11:31:00 (abs_ne_1m_lower_en)
0.919 0.976 0.975 0.975 

10k,en,ABS+NE+use_lower=TRUE 2022-02-11 11:31:00 
  acc    hP    hR    hF 
0.688 0.890 0.872 0.881

10k,en,ABS+NE+use_lower=FALSE 2022-02-11 11:31:00 
  acc    hP    hR    hF 
0.673 0.876 0.863 0.869 

1M,en,ABS+use_lower=TRUE 2022-02-11 14:08:50"
  acc    hP    hR    hF 
0.888 0.969 0.968 0.968 

1M,en,ABS+NER(use_printable_names=TRUE)+PP(use_lower=TRUE,use_steam=TRUE) 2022-02-13 09:51:34"
  acc    hP    hR    hF 
0.917 0.975 0.975 0.975 
---- test pp ---


pp svm en 1m
base:
| 1M        | 0.880 | 0.956 | 0.959 | 0.957 |

lower:
[1] "4. Using preprocessing before vectorization"
[1] "Lowercasing abstracts"
[1] "    rebuilding abstracts¨"
  acc    hP    hR    hF 
0.867 0.950 0.953 0.952 
[1] "Accuracy:  0.866610346369826"
[1] "Hierarchical Precission:  0.949992308644274"
[1] "Hierarchical Recall:  0.953478221501986"
[1] "Hierarchical F measure:  0.951732073117106"

stw:
[1] "4. Using preprocessing before vectorization"
[1] "    Removing Stopwords"
[1] "    rebuilding abstracts¨"
  acc    hP    hR    hF 
0.870 0.949 0.953 0.951 
[1] "Accuracy:  0.869974655866422"
[1] "Hierarchical Precission:  0.949157717950023"
[1] "Hierarchical Recall:  0.952584375573164"
[1] "Hierarchical F measure:  0.950867959596802"

stem:
[1] "4. Using preprocessing before vectorization"
[1] "    Applying stemming"
[1] "    rebuilding abstracts¨"
  acc    hP    hR    hF 
0.868 0.950 0.953 0.952 
[1] "Accuracy:  0.868135963822492"
[1] "Hierarchical Precission:  0.950179908136938"
[1] "Hierarchical Recall:  0.953360976776258"
[1] "Hierarchical F measure:  0.951767784463337"

lemma: 
[1] "4. Using preprocessing before vectorization"
[1] "    Applying lematization"
[1] "    rebuilding abstracts¨"
  acc    hP    hR    hF 
0.871 0.951 0.954 0.953 
[1] "Accuracy:  0.870660438304428"
[1] "Hierarchical Precission:  0.951233090434348"
[1] "Hierarchical Recall:  0.954062123452892"
[1] "Hierarchical F measure:  0.952645506631878"

punct:
[1] "4. Using preprocessing before vectorization"
  acc    hP    hR    hF 
0.878 0.955 0.958 0.956 
[1] "Accuracy:  0.878447547582368"
[1] "Hierarchical Precission:  0.954768271975645"
[1] "Hierarchical Recall:  0.958206318213794"
[1] "Hierarchical F measure:  0.956484205622963"


10k 
	  acc    hP    hR    hF 
	0.758 0.913 0.909 0.911 
	  acc    hP    hR    hF 
	0.358 0.794 0.762 0.778 
1m
	model: 0.916 0.975 0.975 0.975
	gs:
	  acc    hP    hR    hF 
	0.571 0.892 0.885 0.888 
3m 
	0.929 0.979 0.979 0.979 
	  acc    hP    hR    hF 
	0.583 0.897 0.890 0.894