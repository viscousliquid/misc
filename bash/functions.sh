
function int_to_char()
{
	local int=$1
	local __resultvar=$2

	local hex=$(printf "\\\x%x" $int)
	local char=$(printf "$hex")

	eval $__resultvar="'$char'"
}

function read_register()
{
	local address=$(echo $(($1)) )
	local __resultvar=$2

	local reg=$(sudo dd bs=1 count=1 skip=$address if=/dev/port 2>/dev/null)
	local hex=$(printf "$reg" | hexdump -v -e '/1 "%02x"')

        eval $__resultvar="'0x$hex'"
}

function write_register()
{
	local address=$(echo $(($1)) )
	local value=$2
	local __resultvar=$3

	# Write value to register
	$(printf "$value" | sudo dd bs=1 count=1 seek=$address of=/dev/port 2>/dev/null)

	# Read register to return for verification
	local reg=$(sudo dd bs=1 count=1 skip=$address if=/dev/port 2>/dev/null)
	local hex=$(printf "$reg" | hexdump -v -e '/1 "%02x"')

        eval $__resultvar="'0x$hex'"
}

function flip_reg_bit()
{
	local address=$1
	local value=$(( 1 << $2 ))

	int_to_char $value result
	write_register $address $result result

	echo "Register value: ${result}"
}
