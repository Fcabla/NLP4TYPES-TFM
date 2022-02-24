import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt
data = {'size%': [0.01666, 0.01844, 0.02075, 0.02371, 0.02766, 0.0332, 0.0415, 0.05533, 0.083, 0.166, 0.3],
		'Acc': [0.844, 0.848, 0.850, 0.853, 0.855, 0.861, 0.864, 0.868, 0.875, 0.881, 0.881],
		'hPrec': [0.941, 0.942, 0.943, 0.944, 0.946, 0.948, 0.950, 0.952, 0.955, 0.958, 0.958],
		'hRec': [0.941, 0.943, 0.943, 0.945, 0.947, 0.949, 0.951, 0.953, 0.956, 0.959, 0.959],
		'hF': [0.941, 0.942, 0.943, 0.945, 0.946, 0.949, 0.950, 0.952, 0.955, 0.958, 0.958],
}
dataes = {'size%': [0.01666, 0.03332, 0.04998, 0.06664, 0.0833, 0.09996, 0.11662, 0.13328, 0.14994, 0.1666, 0.18326, 0.19992, 0.21658, 0.23324, 0.2499, 0.26656, 0.28322, 0.29988, 0.31654, 0.3332],
        'Acc': [0.871, 0.890, 0.897, 0.902, 0.906, 0.908, 0.911, 0.911, 0.914, 0.915, 0.916, 0.917, 0.917, 0.919, 0.919, 0.919, 0.920, 0.921, 0.921, 0.921],
        'hPrec': [0.945, 0.955, 0.960, 0.962, 0.965, 0.966, 0.967, 0.967, 0.968, 0.969, 0.969, 0.970, 0.970, 0.971, 0.971, 0.971, 0.971, 0.972, 0.972, 0.972],
        'hRec': [0.952, 0.960, 0.964, 0.965, 0.968, 0.969, 0.970, 0.970, 0.971, 0.972, 0.972, 0.972, 0.973, 0.973, 0.973, 0.973, 0.973, 0.974, 0.974, 0.974],
        'hF': [0.948, 0.958, 0.962, 0.964, 0.967, 0.967, 0.968, 0.969, 0.970, 0.970, 0.970, 0.971, 0.971, 0.972, 0.972, 0.972, 0.972, 0.973, 0.973, 0.973],
}

#df = pd.DataFrame(data)
df = pd.DataFrame(dataes)

ax =  sns.relplot(
    data=df, kind="line",
    x="size%", y="Acc", 
    facet_kws=dict(sharex=False),
)
ax.set(xlabel='% dataset', ylabel='Precisión')
plt.savefig('learning_curve_es.svg')
#col="align", hue="choice", size="coherence", style="choice",
'''

Learning curve
\begin{table}[htbp]
    \centering
    \begin{tabular}{cccccc}
        \toprule
        \multicolumn{2}{c}{Resources}&\\
        \cline{1-2} 
        min doc & min term & Acc & hPrec & hRec & hF\\
        \midrule
        0.01666 & 0.844 & 0.941 & 0.941 & 0.941\\
        0.01844 & 0.848 & 0.942 & 0.943 & 0.942\\
        0.02075 & 0.850 & 0.943 & 0.943 & 0.943\\
        0.02371 & 0.853 & 0.944 & 0.945 & 0.945\\
        0.02766 & 0.855 & 0.946 & 0.947 & 0.946\\
        0.0332 & 0.861 & 0.948 & 0.949 & 0.949\\
        0.0415 & 0.864 & 0.950 & 0.951 & 0.950\\
        0.05533 & 0.868 & 0.952 & 0.953 & 0.952\\
        0.083 & 0.875 & 0.955 & 0.956 & 0.955\\
        \midrule
        0.166 & 0.881 & 0.958 & 0.959 & 0.958\\
        \bottomrule
    \end{tabular}
    \caption{Rendimiento del sistema actual al recortar la matriz con distintos valores en los parametros min termfreq y min docfreq con 10k de abstracts}
    \label{tab:resultados_recortar_matriz_tdm2}
\end{table}
'''