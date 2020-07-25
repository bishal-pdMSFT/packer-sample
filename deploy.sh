script_dir=$(dirname "$0")
echo $script_dir
echo "$1"
rm -rf "./$1"
mkdir "./$1"
cp ./dummy.tar.gz "./$1"

if [ "$2" == "true" ]; then
    echo "some custom error!" 1>&2
    exit 1
fi
