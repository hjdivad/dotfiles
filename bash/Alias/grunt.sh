# Prefixing the current directory makes linked packages work as expected.  Node
# walks backwards up the file system to search for modules, but it seems to
# escape symlinked paths when doing this.
alias g='NODE_PATH=`pwd`/node_modules grunt'
