# Ruby stream editor; a simple, primitive ruby analog to sed.
alias rsed="ruby -p -e '%w(rubygems active_support).each{|l| require l}' \
            -e 'def s *args; \$_.gsub! *args; end'"
alias chomp="rsed -e '\$_.chomp!'"
alias b="bundle exec"
