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
| Full(3M)  | 0.xxx | 0.xxx | 0.xxx | 0.xxx |

*********************************************************************************

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

*********************************************************************************

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
| Full(3M)  | 0.xxx | 0.xxx | 0.xxx | 0.xxx |
|-----------|-------|-------|-------|-------|
| hSVM      | 0.548 | 0.890 | 0.665 | 0.761 |
| SDType    | 0.338 | 0.809 | 0.641 | 0.715 |

*********************************************
Testing of new possible upgrades with 1Million instances:
	- printable names = SoccerPlayer -> Soccer Player
	- path2root = SoccerPlayer -> owl:Thing, Agent, Person, Athlete, SoccerPlayer


| printable names | path2root | Acc   | hPrec | hRec  | hF    |
|-----------------|-----------|-------|-------|-------|-------|
| -               | -         | 0.880 | 0.956 | 0.959 | 0.957 |
| +               | -         | 0.873 | 0.955 | 0.955 | 0.955 |
| -               | +         | 0.879 | 0.957 | 0.959 | 0.958 |
| +               | +         | 0.869 | 0.953 | 0.956 | 0.955 |

*********************************************
*********************************************
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
*********************************************
(146 unique classes on the spanish dbpedia dataset vs 405 unique classes on the english dbpedia dataset)
Despite having less data, the Spanish version performs better than the English version. It is believed that this is due to the number of possible classes in both datasets. 
