# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin provides useful credit card capabilities
    module URIScheme
      # Supported Method Parameters::
      # uri_scheme_arr = CSI::Plugins::URIScheme.list_all_known

      public_class_method def self.list_all_known
        uri_scheme_arr = [
          'aaa',
          'aaas',
          'about',
          'acap',
          'acct',
          'acr',
          'adiumxtra',
          'afp',
          'afs',
          'aim',
          'appdata',
          'apt',
          'attachment',
          'aw',
          'barion',
          'beshare',
          'bitcoin',
          'bitcoincash',
          'blob',
          'bolo',
          'browserext',
          'calculator',
          'callto',
          'cap',
          'chrome',
          'chrome-extension',
          'cid',
          'coap',
          'coap+tcp',
          'coap+ws',
          'coaps',
          'coaps+tcp',
          'coaps+ws',
          'com-eventbrite-attendee',
          'content',
          'conti',
          'crid',
          'cvs',
          'data',
          'dav',
          'diaspora',
          'dict',
          'did',
          'dis',
          'dlna-playcontainer',
          'dlna-playsingle',
          'dns',
          'dntp',
          'dtn',
          'dvb',
          'ed2k',
          'elsi',
          'example',
          'facetime',
          'fax',
          'feed',
          'feedready',
          'file',
          'filesystem',
          'finger',
          'fish',
          'ftp',
          'geo',
          'gg',
          'git',
          'gizmoproject',
          'go',
          'gopher',
          'graph',
          'gtalk',
          'h323',
          'ham',
          'hcap',
          'hcp',
          'http',
          'https',
          'hxxp',
          'hxxps',
          'hydrazone',
          'iax',
          'icap',
          'icon',
          'im',
          'imap',
          'info',
          'iotdisco',
          'ipn',
          'ipp',
          'ipps',
          'irc',
          'irc6',
          'ircs',
          'iris',
          'iris.beep',
          'iris.lwz',
          'iris.xpc',
          'iris.xpcs',
          'isostore',
          'itms',
          'jabber',
          'jar',
          'jms',
          'keyparc',
          'lastfm',
          'ldap',
          'ldaps',
          'lvlt',
          'magnet',
          'mailserver',
          'mailto',
          'maps',
          'market',
          'message',
          'microsoft.windows.camera',
          'microsoft.windows.camera.multipicker',
          'microsoft.windows.camera.picker',
          'mid',
          'mms',
          'modem',
          'mongodb',
          'moz',
          'ms-access',
          'ms-browser-extension',
          'ms-calculator',
          'ms-drive-to',
          'ms-enrollment',
          'ms-excel',
          'ms-eyecontrolspeech',
          'ms-gamebarservices',
          'ms-gamingoverlay',
          'ms-getoffice',
          'ms-help',
          'ms-infopath',
          'ms-inputapp',
          'ms-lockscreencomponent-config',
          'ms-media-stream-id',
          'ms-mixedrealitycapture',
          'ms-officeapp',
          'ms-people',
          'ms-project',
          'ms-powerpoint',
          'ms-publisher',
          'ms-restoretabcompanion',
          'ms-screenclip',
          'ms-screensketch',
          'ms-search',
          'ms-search-repair',
          'ms-secondary-screen-controller',
          'ms-secondary-screen-setup',
          'ms-settings',
          'ms-settings-airplanemode',
          'ms-settings-bluetooth',
          'ms-settings-camera',
          'ms-settings-cellular',
          'ms-settings-cloudstorage',
          'ms-settings-connectabledevices',
          'ms-settings-displays-topology',
          'ms-settings-emailandaccounts',
          'ms-settings-language',
          'ms-settings-location',
          'ms-settings-lock',
          'ms-settings-nfctransactions',
          'ms-settings-notifications',
          'ms-settings-power',
          'ms-settings-privacy',
          'ms-settings-proximity',
          'ms-settings-screenrotation',
          'ms-settings-wifi',
          'ms-settings-workplace',
          'ms-spd',
          'ms-sttoverlay',
          'ms-transit-to',
          'ms-useractivityset',
          'ms-virtualtouchpad',
          'ms-visio',
          'ms-walk-to',
          'ms-whiteboard',
          'ms-whiteboard-cmd',
          'ms-word',
          'msnim',
          'msrp',
          'msrps',
          'mtqp',
          'mumble',
          'mupdate',
          'mvn',
          'news',
          'nfs',
          'ni',
          'nih',
          'nntp',
          'notes',
          'ocf',
          'oid',
          'onenote',
          'onenote-cmd',
          'opaquelocktoken',
          'openpgp4fpr',
          'pack',
          'palm',
          'paparazzi',
          'pkcs11',
          'platform',
          'pop',
          'pres',
          'prospero',
          'proxy',
          'pwid',
          'psyc',
          'qb',
          'query',
          'redis',
          'rediss',
          'reload',
          'res',
          'resource',
          'rmi',
          'rsync',
          'rtmfp',
          'rtmp',
          'rtsp',
          'rtsps',
          'rtspu',
          'secondlife',
          'service',
          'session',
          'sftp',
          'sgn',
          'shttp',
          'sieve',
          'simpleledger',
          'sip',
          'sips',
          'skype',
          'smb',
          'sms',
          'smtp',
          'snews',
          'snmp',
          'soap.beep',
          'soap.beeps',
          'soldat',
          'spiffe',
          'spotify',
          'ssh',
          'steam',
          'stun',
          'stuns',
          'submit',
          'svn',
          'tag',
          'teamspeak',
          'tel',
          'teliaeid',
          'telnet',
          'tftp',
          'things',
          'thismessage',
          'tip',
          'tn3270',
          'tool',
          'turn',
          'turns',
          'tv',
          'udp',
          'unreal',
          'urn',
          'ut2004',
          'v-event',
          'vemmi',
          'ventrilo',
          'videotex',
          'vnc',
          'view-source',
          'wais',
          'webcal',
          'wpid',
          'ws',
          'wss',
          'wtai',
          'wyciwyg',
          'xcon',
          'xcon-userid',
          'xfire',
          'xmlrpc.beep',
          'xmlrpc.beeps',
          'xmpp',
          'xri',
          'ymsgr',
          'z39.50',
          'z39.50r',
          'z39.50s'
        ]
      rescue => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts "USAGE:
          uri_scheme_arr = #{self}.list_all_known

          #{self}.authors
        "
      end
    end
  end
end
