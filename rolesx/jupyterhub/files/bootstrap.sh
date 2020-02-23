#!/bin/bash

[ $(whoami) == "root" ] && exec sudo -u ${1:-nobody} $0

PYTHON3=$(ls /bin/python3* /usr/bin/python3 /usr/local/bin/python3* | head -1 2> /dev/null)
JUPYTER=$(ls /bin/jupyter /usr/bin/jupyter /usr/local/bin/jupyter /opt/conda/bin/jupyter ~/bin/jupyter ~/local/bin/jupyter | head -1 2> /dev/null)

set -x
exec > ~/bootstrap.log 2>&1

if [ ! -x "$JUPYTER" ]; then
  echo "Cannot exec jupyter"
  exit 1
fi

cp -a /etc/jupyterhub/00-requires.py ~/.ipython/profile_default/startup/

$PYTHON3 -m bash_kernel.install
$JUPYTER contrib nbextension install --user
$JUPYTER nbextension enable widgetsnbextension --user --py
$JUPYTER nbextension install lc_multi_outputs --user --py
$JUPYTER nbextension enable lc_multi_outputs --user --py
for ext in collapsible_headings toc2; do
  $JUPYTER nbextension enable $ext/main --user
done

[ -f ~/.gitconfig ] || cat <<EOF > ~/.gitconfig
[filter "clean_ipynb"]
    clean = jq --indent 1 --monochrome-output '. + if .metadata.git.suppress_outputs | not then { cells: [.cells[] | . + if .cell_type == \"code\" then { outputs: [], execution_count: null } else {} end ] } else {} end'
    smudge = cat
EOF

[ -f ~/.gitattributes ] || cat <<EOF > ~/.gitattributes
*.ipynb  filter=clean_ipynb
EOF
