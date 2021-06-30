#!/bin/bash
echo "Installing riemann-tools gem ... "
if gem list | grep --quiet -w mtrc; then
        echo "mtrc exists"
else
        echo "mtrc doesnt exist.. installing"
	gem install  mtrc -v 0.0.4
fi

if gem list | grep --quiet -w beefcake; then
        echo "beefcake exists"
else
        echo "beefcake doesnt exist.. installing"
	gem install  beefcake -v 1.0.0
fi

if gem list | grep --quiet -w trollop; then
        echo "trollop exists"
else
        echo "trollop doesnt exist.. installing"
	gem install  trollop -v 2.1.2
fi

if gem list | grep --quiet -w json; then
        echo "json exists"
else
        echo "json doesnt exist.. installing"
	gem install  json -v 1.8.3
fi

if gem list | grep --quiet -w riemann-client; then
        echo "riemann-client exists"
else
        echo "riemann-client doesnt exist.. installing"
	gem install  riemann-client -v 0.2.6
fi

if gem list | grep --quiet -w riemann-tools; then
        echo "riemann-tools exists"
else
        echo "riemann-tools doesnt exist.. installing"
	gem install  riemann-tools -v 0.2.10
fi
exit 0
