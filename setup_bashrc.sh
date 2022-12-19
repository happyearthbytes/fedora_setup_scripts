
# export LESS="--RAW-CONTROL-CHARS"

# add_line - a function to add a line to a file if it does not already exist
# usage: add_line LINE FILE
add_line() {
  local line=$1
  local file=$2
  # Create the file if it doesn't exist
  [ -f $file ] || touch $file
  # add the line to the end of the file if it does not already exist
  grep -qxF "$line" $file || echo "$line" >> $file
}
