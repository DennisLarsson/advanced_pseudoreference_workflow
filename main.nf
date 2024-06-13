process optimization {
    container 'ghcr.io/dennislarsson/stacks2-image:refs-tags-1.1.1-4480f63'
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
