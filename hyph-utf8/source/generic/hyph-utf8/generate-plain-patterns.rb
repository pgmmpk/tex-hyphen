#!/usr/bin/env ruby

# this file generates plain patterns (one-per-line) out of TeX source

# use 'gem install unicode' if unicode is missing on your computer
require 'jcode'
require 'rubygems'
require 'unicode'

load 'languages.rb'

$path_plain="../../../../plain"

$l = Languages.new
# TODO: should be singleton
languages = $l.list.sort{|a,b| a.name <=> b.name}

# TODO: we should rewrite this
# not using: eo, el
# todo: mn, no!, sa, sh
# codes = ['bg', 'ca', 'cs', 'cy', 'da', 'de-1901', 'de-1996', 'de-ch-1901', 'en-gb', 'en-us', 'es', 'et', 'eu', 'fi', 'fr', 'ga', 'gl', 'hr', 'hsb', 'hu', 'ia', 'id', 'is', 'it', 'kmr', 'la', 'lt', 'lv', 'nl', 'no', 'pl', 'pt', 'ro', 'ru', 'sk', 'sl', 'sr-cyrl', 'sv', 'tr', 'uk']

language_codes = Hash.new
languages.each do |language|
	language_codes[language.code] = language.code
end
# language_codes['de-1901']      = 'de-1901'
# language_codes['de-1996']      = 'de-1996'
language_codes['de-ch-1901']   = 'de-CH-1901'
language_codes['en-gb']        = 'en-GB'
language_codes['en-us']        = 'en-US'
language_codes['zh-latn']      = 'zh-Latn'
# language_codes['el-monoton']   = 'el-monoton'
# language_codes['el-polyton']   = 'el-polyton'
language_codes['mn-cyrl']      = nil
language_codes['mn-cyrl-x-2a'] = 'mn'
language_codes['sh-latn']      = 'sr-Latn'
language_codes['sh-cyrl']      = nil
language_codes['sr-cyrl']      = 'sr-Cyrl'

languages.sort{|x,y| x.code <=> y.code }.each do |language|
	if language.use_new_loader or language.code == 'en-us' then
		include_language = true
	else
		include_language = false
		puts "(skipping #{language.code})"
	end

	code = language_codes[language.code]
	if code == nil
		include_language = false
	end
	if code == 'en_US'
		include_language = true
	end

	if include_language
		puts "generating #{code}"
	
		$file_pat = File.open("#{$path_plain}/#{code}.pat.txt", 'w')
		$file_hyp = File.open("#{$path_plain}/#{code}.hyp.txt", 'w')
		$file_let = File.open("#{$path_plain}/#{code}.chr.txt", 'w')
		$file_inf = File.open("#{$path_plain}/#{code}.lic.txt", 'w')

		patterns   = language.get_patterns
		exceptions = language.get_exceptions

		if code == 'nn' or code == 'nb'
			patterns = ""
			patterns = $l['no'].get_patterns
		end

		characters_indexes = patterns.join('').gsub(/[.0-9]/,'').unpack('U*').sort.uniq

		# patterns
		patterns.each do |pattern|
			$file_pat.puts pattern.gsub(/'/,"’")
		end
		# exceptions
		if exceptions != ""
			$file_hyp.puts exceptions
		end
		# letters
		characters_indexes.each do |c|
			ch = [c].pack('U')
			$file_let.puts ch + Unicode.upcase(ch)
		end
		# licence and readme
		$file_inf.puts "#{language.message}\n\n(more info about the licence to be added later)\n\n"
		$file_inf.puts language.get_comments_and_licence

		$file_pat.close
		$file_hyp.close
		$file_let.close
		$file_inf.close
	end
end