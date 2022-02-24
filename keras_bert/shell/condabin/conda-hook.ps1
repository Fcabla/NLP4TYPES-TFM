$Env:CONDA_EXE = "/home/fcabla/Documentos/UPM/TFM/keras_bert/bin/conda"
$Env:_CE_M = ""
$Env:_CE_CONDA = ""
$Env:_CONDA_ROOT = "/home/fcabla/Documentos/UPM/TFM/keras_bert"
$Env:_CONDA_EXE = "/home/fcabla/Documentos/UPM/TFM/keras_bert/bin/conda"
$CondaModuleArgs = @{ChangePs1 = $True}

Import-Module "$Env:_CONDA_ROOT\shell\condabin\Conda.psm1" -ArgumentList $CondaModuleArgs
Remove-Variable CondaModuleArgs