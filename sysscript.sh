mnesiadir=$2
defaultNodeName="a0"
node=$1
if [ -z "$node" ] ;
then 
    node=$defaultNodeName
else 
    node=$node ; 
fi
echo "Node name set to : $node"
defaultMnesiaDir="$(pwd)/a/mnesia"
defaultDir=0
if [ -z "$mnesiadir" ] ;
then 
    defaultDir=1
    mnesiadir=$defaultMnesiaDir
else 
    mnesiadir=$mnesiadir ; 
fi

echo "Using mnesiaDir : [$mnesiadir]"
mkdir $mnesiadir
erl -sname $node -mnesia dir $mnesiadir -s mnesia