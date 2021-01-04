# frozen_string_literal: true

LANG = 'en_US.UTF-8'
LC_ALL = 'en_US.UTF-8'
source 'https://rubygems.org'

# *** => Represents Gems that didn't have new versions available during the last gem update (6/28/2016).  Implies lack of development.
# Specify your gem's dependencies in csi.gemspec
gemspec

gem 'activesupport', '6.1.0'         # Required to properly build csi via rake w/in ruby-2.3.0 ***2020-12-15
gem 'anemone', '0.7.2'                 # Spider webpagesa ***2017-03-30
gem 'authy', '3.0.0'                   # MFA API Access into Authy service ***2020-12-15
gem 'aws-sdk', '3.0.1'                 # Amazon AWS SDK ***2017-12-18
gem 'bettercap', '1.6.2'               # MITM framework ***2017-12-18
gem 'brakeman', '4.10.1'                # Rails Security Scanner ***2021-01-04
gem 'bson', '4.11.1'                    # Required for mongo gem installation see https://api.mongodb.org/ruby/1.10.2/ ***2020-12-15
gem 'bundler', '2.2.4'                 # bundle install ***2021-01-04
gem 'bundler-audit', '0.7.0.1'         # Checks for vulnerable versions of gems ***2020-09-17
gem 'bunny', '2.17.0'                  # RabbitMQ ***2020-09-17
gem 'credit_card_validations', '3.5.1' # validate ccno from luhn generation ***2019-12-18
gem 'gdb', '1.0.0'                    # support debugging binaries ***2020-06-18
gem 'gist', '6.0.0'                    # support gist command in csi prototyping driver gist -o 1..3 ***2020-09-17
gem 'htmlentities', '4.3.4'            # Encode raw strings/input to HTML entity encoded data ***2016-06-28
gem 'ipaddress', '0.8.3'               # Validate IP Addresses ***2017-04-04
#gem 'jenkins_api_client', '1.5.3'      # Support Jenkins Continuous Integration Automation ***2016-03-30
gem 'js-beautify', '0.1.8'             # Nest JavaScript Files for Read-Ability ***2016-06-28
gem 'json', '2.5.1'                    # Work w/ JSON objects ***2021-01-04
gem 'jsonpath', '1.1.0'                # XPath-ify Complex JSON Data Structures ***2021-01-04
gem 'jwt', '2.2.2'                     # Support JWT creation jwt.io/#debugger-io ***2020-11-23
gem 'luhn', '1.0.2'                    # validate id nums (e.g. ccno, IMEI, US National Provider IDs & Canadian Social Insurance Numbers ***2017-02-16)
gem 'mail', '2.7.1'                    # Required for Mail Agent to Distribute Alert Notifications, Reports, etc ***2019-01-08
gem 'mongo', '2.14.0'                  # Primarily for Data-Driven Security, pulling in various security tools' output ***2020-12-15
gem 'msfrpc-client', '1.1.2'           # Metasploit API - Per Rapid7 this is the preferred way to interact w/ MSF in external tools ***2019-01-08
gem 'net-ldap', '0.17.0'               # Required for Querying Active Directory Domain Controllers/LDAP Servers ***2020-12-15
gem 'net-openvpn', '0.8.7'             # Used for OpenVPN connectivity ***2017-02-13
gem 'nexpose', '7.2.1'                 # Vuln Scan all the Things! ***2019-01-08
gem 'nokogiri', '1.11.0'               # Parse HTML & XML Documents ***2021-01-04
gem 'oily_png', '1.2.1'                # waveform Gem Dependency ***2017-08-20
gem 'os', '1.1.1'                      # Detect underlying operating system ***2020-09-17
gem 'packetfu', '1.1.13'               # Bettercap dependency and misc packet mangler ***2017-04-28
gem 'pdf-reader', '2.4.1'              # Parsing PDF Reports ***2020-12-15
gem 'pg', '1.2.3'                      # Required Postgres Gem for Postgres Data Access Object ***2020-03-26
gem 'pry', '0.13.1'                    # More feature-filled irb alternative ***2020-04-13
gem 'pry-doc', '1.1.0'                 # Better support for show-source & show-method in csi prototyper ***2020-03-30
gem 'rb-readline', '0.5.5'             # Required for pry / csi prototyping driver ***2017-03-30
gem 'rbvmomi', '3.0.0'                 # Required for VMware-Fu ***2020-09-17
gem 'rest-client', '2.1.0'             # Required for REST API Testing ***2019-10-11
gem 'rex', '2.0.13'                    # Rex provides a variety of classes useful for security testing and exploit development ***2019-01-08
gem 'rmagick', '4.1.2'                 # Image processing gem ***2020-04-13
gem 'rtesseract', '3.1.2'              # Gem for image ocr (e.g. decoding captchas) ***2020-09-17
gem 'rubocop', require: false          # Ruby static code analyzer. Out of the box it will enforce many of the guidelines outlined in the community Ruby Style Guide.
gem 'ruby-audio', '1.6.1'              # Gem for massaging audio ***2017-03-12
gem 'ruby-nmap', '0.10.0'              # A Ruby interface to nmap, the exploration tool and security / port scanner ***2020-03-26
gem 'ruby-saml', '1.11.0'              # Support client-side SAML Authorization & Configuring w/ existing IDPs (e.g. OneLogin) ***2019-08-13
gem 'rvm', '1.11.3.9'                  # Leverage this gem for switching gemsets w/in deployment scripts w/in Vagrant ***2016-06-28
gem 'savon', '2.12.1'                  # Required for SOAP API Testing ***2020-07-29
gem 'serialport', '1.3.1'              # Serial based communications, wardialing, arduino, etc ***2016-06-28
gem 'sinatra', '2.1.0'                 # Used for Phishing & Attacker Proof-of-Concept Demonstrations ***2020-09-17
gem 'slack-ruby-client', '0.15.1'      # Used for interacting w/ Slack via bots ***2020-09-17
gem 'socksify', '1.7.1'                # Used for connecting to SOCKS proxies (e.g. tor) ***2017-08-20
gem 'spreadsheet', '1.2.6'             # Generate Excel Spreadsheets (.xls files) ***2020-02-11
gem 'sqlite3', '1.4.2'                 # Required Sqlite3 Gem for Sqlite3 Data Access Object ***2020-02-11
gem 'thin', '1.8.0'                    # Light HTTP Server Used for Serving Up Sinatra Web Applications ***2020-12-15
gem 'tty-prompt', '0.23.0'             # Masking Authentication Credential Input ***2020-12-15
gem 'webrick', '1.7.0'                 # Light HTTP Server, Dependency of Anemone Gem ***2021-01-04
gem 'watir', '6.17.0'                  # Drive Various Web Browsers (IE, Chrome, Firefox, headless) ***2020-09-17
gem 'waveform', '0.1.2'                # Generate waveform from WAV files ***2017-03-12
gem 'wicked_pdf', '2.1.0'              # Convert HTML to PDF Documents ***2020-09-17
