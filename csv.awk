BEGIN {
	gsub(/ /,"", delim)
	split_on_delim = "([^" delim "]*)|(\"[^\"]+\")"
	FPAT = split_on_delim
}

{
	print $2
}
