# frozen_string_literal: true

LANG = 'en_US.UTF-8'
LC_ALL = 'en_US.UTF-8'
source 'https://rubygems.org'

# *** => Represents Gems that didn't have new versions available during the last gem update (6/28/2016).  Implies lack of development.
# Specify your gem's dependencies in csi.gemspec
gemspec

gem 'activesupport', '5.0.2'           # Required to properly build csi via rake w/in ruby-2.3.0 ***2017-03-30
gem 'anemone', '0.7.2'                 # Spider webpages
gem 'authy', '2.7.1'                   # MFA API Access into Authy service ***2017-02-13
gem 'aws-sdk', '2.9.3'                 # Amazon AWS SDK ***2017-04-04
gem 'bettercap', '1.6.0'               # MITM framework ***2017-02-13
gem 'brakeman', '3.6.1'                # Rails Security Scanner ***2017-04-04
gem 'bson', '4.2.1'                    # Required for mongo gem installation see https://api.mongodb.org/ruby/1.10.2/ ***2017-02-13
gem 'bundler-audit', '0.5.0'           # Checks for vulnerable versions of gems ***2017-02-13
gem 'bunny', '2.6.4'                   # RabbitMQ ***2017-04-04
gem 'credit_card_validations', '3.4.0' # validate ccno from luhn generation
gem 'highline', '1.7.8'                # Masking Authentication Credential Input ***2016-06-28
gem 'htmlentities', '4.3.4'            # Encode raw strings/input to HTML entity encoded data ***2016-06-28
gem 'ipaddress', '0.8.3'               # Validate IP Addresses ***2017-04-04
gem 'jenkins_api_client', '1.5.3'      # Support Jenkins Continuous Integration Automation ***2016-03-30
gem 'js-beautify', '0.1.8'             # Nest JavaScript Files for Read-Ability ***2016-06-28
gem 'json', '2.0.3'                    # Work w/ JSON objects ***2017-03-30 (jenkins_api_client depends on older version)
gem 'jsonpath', '0.5.8'                # XPath-ify Complex JSON Data Structures ***2017-02-13
gem 'luhn', '1.0.2'                    # validate id nums (e.g. ccno, IMEI, US National Provider IDs & Canadian Social Insurance Numbers ***2017-02-16)
gem 'mongo', '2.4.1'                   # Primarily for Data-Driven Security, pulling in various security tools' output ***2017-02-13
gem 'msfrpc-client', '1.1.0'           # Metasploit API - Per Rapid7 this is the preferred way to interact w/ MSF in external tools ***2017-03-30
gem 'msgpack', '1.1.0'                 # Pry Dependency ***2017-03-30
gem 'net-ldap', '0.16.0'               # Required for Querying Active Directory Domain Controllers/LDAP Servers ***2017-04-04
gem 'net-openvpn', '0.8.7'             # Used for OpenVPN connectivity ***2017-02-13
gem 'nexpose', '6.0.0'                 # Vuln Scan all the Things! ***2017-04-04
gem 'nokogiri', '1.8.0'                # Parse HTML & XML Documents ***2017-06-14 (jenkins_api_client depends on older version)
gem 'oily_png', '1.2.1'                # waveform Gem Dependency ***2017-03-12
gem 'os', '1.0.0'                      # Detect underlying operating system ***2017-04-04
gem 'packetfu', '1.1.13'               # Bettercap dependency and misc packet mangler ***2017-04-28
gem 'pdf-reader', '2.0.0'              # Parsing PDF Reports ***2017-04-04
gem 'pg', '0.20.0'                     # Required Postgres Gem for Postgres Data Access Object ***2017-04-04
gem 'pony', '1.11'                     # Required for Mail Agent to Distribute Alert Notifications, Reports, etc ***2015-12-15
gem 'pry', git: 'https://github.com/tnorris/pry.git', ref: 'adds-duplicate-history' # More feature-filled irb alternative
# gem 'pry', '0.10.4' # More feature-filled irb alternative
gem 'rb-readline', '0.5.4'             # Required for pry / csi prototyping driver ***2017-03-30
gem 'rbvmomi', '1.10.0'                # Required for VMware-Fu ***2017-04-04
gem 'rest-client', '2.0.0'             # Required for REST API Testing ***2017-02-13
gem 'rex', '2.0.10'                    # Rex provides a variety of classes useful for security testing and exploit development ***2017-02-13
gem 'rmagick', '2.16.0'                # Image processing gem ***2017-02-13
gem 'rtesseract', '2.1.0'              # Gem for image ocr (e.g. decoding captchas) ***2017-02-13
gem 'rubocop', require: false          # Ruby static code analyzer. Out of the box it will enforce many of the guidelines outlined in the community Ruby Style Guide.
gem 'ruby-audio', '1.6.1'              # Gem for massaging audio ***2017-03-12
gem 'ruby-nmap', '0.9.2'               # A Ruby interface to nmap, the exploration tool and security / port scanner ***2017-02-13
gem 'ruby-saml', '1.4.2'               # Support client-side SAML Authorization & Configuring w/ existing IDPs (e.g. OneLogin) ***2017-02-13
gem 'rvm', '1.11.3.9'                  # Leverage this gem for switching gemsets w/in deployment scripts w/in Vagrant ***2016-06-28
gem 'serialport', '1.3.1'              # Serial based communications, wardialing, arduino, etc ***2016-06-28
gem 'sinatra', '1.4.8'                 # Used for Phishing & Attacker Proof-of-Concept Demonstrations ***2017-02-13
gem 'slack-ruby-client', '0.7.9'       # Used for interacting w/ Slack via bots ***2017-02-13
gem 'socksify', '1.7.0'                # Used for connecting to SOCKS proxies (e.g. tor) ***2017-02-13
gem 'spreadsheet', '1.1.4'             # Generate Excel Spreadsheets (.xls files) ***2017-02-13
gem 'sqlite3', '1.3.13'                # Required Sqlite3 Gem for Sqlite3 Data Access Object ***2017-02-13
gem 'thin', '1.7.0'                    # Light HTTP Server Used for Serving Up Sinatra Web Applications ***2017-02-13
gem 'watir', '6.6.2'                   # Drive Various Web Browsers (IE, Chrome, Firefox, headless) ***2017-08-09
gem 'waveform', '0.1.2'                # Generate waveform from WAV files ***2017-03-12
gem 'wicked_pdf', '1.1.0'              # Convert HTML to PDF Documents ***2017-02-13
