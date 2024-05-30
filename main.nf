process optimization {
    container 'stacks2'
    "./optimization.py"
}

process preprocessing {
    container 'preprocessing'
    "./preprocessing.py"
}

process pseudoreference {
    container 'pseudoreference'
    "./pseudoreference.py"
}

process postprocessing {
    container 'stacks2'
    "./postprocessing"
}

workflow {
    optimization | preprocessing | pseudoreference | postprocessing
}