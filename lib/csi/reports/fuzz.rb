# frozen_string_literal: true

require 'json'

module CSI
  module Reports
    # This plugin generates the Static Code Anti-Pattern Matching Analysis
    # results within the root of a given source repo.  Two files are created,
    # a JSON file containing all of the Fuzz results and an HTML file
    # which is essentially the UI for the JSON file.
    module Fuzz
      # Supported Method Parameters::
      # CSI::Reports::Fuzz.generate(
      #   dir_path: dir_path,
      #   results_hash: results_hash
      # )

      public_class_method def self.generate(opts = {})
        dir_path = opts[:dir_path].to_s if File.directory?(opts[:dir_path].to_s)
        raise "CSI Error: Invalid Directory #{dir_path}" if dir_path.nil?

        results_hash = opts[:results_hash]

        # JSON object Completion
        File.open("#{dir_path}/csi_fuzz_net_app_proto.json", 'w') do |f|
          f.print(results_hash.to_json)
        end

        # Report All the Bugs!!! \o/
        html_report = %q{<!DOCTYPE HTML>
        <html>
          <head>

            <link rel="stylesheet" href="//cdn.datatables.net/1.10.19/css/jquery.dataTables.min.css">
            <script src="//ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
            <script src="//cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
            <style>
              body {
                font-family: Verdana, Geneva, sans-serif;
                font-size: 11px;
                color: #084B8A !important;
              }

              a:link {
                color: #0174DF;
                text-decoration: none;
              }

              a:visited {
                color: #B40404;
                text-decoration: none;
              }

              a:hover {
                color: #01A9DB;
                text-decoration: underline;
              }

              a:active {
                color: #610B5E;
                text-decoration: underline;
              }

              .selected { background-color: #D8D8D8 !important; }

              table {
                width: 100%;
                border-spacing:0px;
              }

              table.squish {
                table-layout: fixed;
              }

              td {
                vertical-align: top;
                word-wrap: break-word !important;
              }
            </style>

          </head>

          <body id="csi_body">

            <h1 style="display:inline">
              &nbsp;~&nbsp;<a href="https://github.com/ninp0/csi/tree/master">csi</a>
            </h1><br /><br />

            <div><button type="button" id="button">Rows Selected</button></div><br />
            <div>
              <b>Toggle Column(s):</b>&nbsp;
              <a class="toggle-vis" data-column="1" href="#">Timestamp</a>&nbsp;|&nbsp;
              <a class="toggle-vis" data-column="2" href="#">Request</a>&nbsp;|&nbsp;
              <a class="toggle-vis" data-column="3" href="#">Request Length</a>&nbsp;|&nbsp;
              <a class="toggle-vis" data-column="3" href="#">Response</a>&nbsp;|&nbsp;
              <a class="toggle-vis" data-column="3" href="#">Response Length</a>&nbsp;|&nbsp;
            </div>
            <br /><br />

            <div>
              <table id="csi_fuzz_net_app_proto" class="display" cellspacing="0">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Timestamp</th>
                    <th>Request</th>
                    <th>Request Length</th>
                    <th>Response</th>
                    <th>Response Length</th>
                  </tr>
                </thead>
                <!-- DataTables <tbody> -->
              </table>
            </div>

            <script>
              var line_entry_uri = "";
              $(document).ready(function() {
                var oldStart = 0;
                var table = $('#csi_fuzz_net_app_proto').DataTable( {
                  "paging": true,
                  "pagingType": "full_numbers",
                  "fnDrawCallback": function ( oSettings ) {
                    /* Need to redo the counters if filtered or sorted */
                    if ( oSettings.bSorted || oSettings.bFiltered ) {
                      for ( var i=0, iLen=oSettings.aiDisplay.length ; i<iLen ; i++ ) {
                        $('td:eq(0)', oSettings.aoData[ oSettings.aiDisplay[i] ].nTr ).html( i+1 );
                      }
                    }
                    // Jump to top when utilizing pagination
                    if ( oSettings._iDisplayStart != oldStart ) {
                      var targetOffset = $('#csi_body').offset().top;
                      $('html,body').animate({scrollTop: targetOffset}, 500);
                      oldStart = oSettings._iDisplayStart;
                    }
                    // Select individual lines in a row
                    $('#multi_line_select tbody').on('click', 'tr', function () {
                      $(this).toggleClass('selected');
                      if ($('#multi_line_select tr.selected').length > 0) {
                        $('#multi_line_select tr td button').attr('disabled', 'disabled');
                        // Remove multi-line bug button
                      } else {
                        $('#multi_line_select tr td button').removeAttr('disabled');
                        // Add multi-line bug button
                      }
                    });
                  },
                  "ajax": "csi_fuzz_net_app_proto.json",
                  "dom": "fplitfpliS",
                  "autoWidth": false,
                  "columns": [
                    { "data": null },
                    {
                      "data": "timestamp",
                      "render": function (data, type, row, meta) {
                        return '<a name="' + encodeURIComponent(data) + '">' + data + '</a>';
                      }
                    },
                    {
                      "data": "request",
                      "render": function (data, type, row, meta) {
                        // convert camel-cased scapm modules to use underscore naming instead to ensure the test case can resolve to the proper csi github url in the report
                        return '<tr><td style="width:150px;" align="left"><a href="https://github.com/ninp0/csi/tree/master/lib/' + data['sp_module'].replace(/::/g, "/").toLowerCase() + '.rb" target="_blank">' + data['sp_module'].split("::")[2] + '</a><br /><a href="' + data['nist_800_53_uri'] + '" target="_blank">' + data['section']  + '</a></td></tr>';
                      }
                    },
                    {
                      "data": "request_len",
                      "render": function (data, type, row, meta) {
                        for (var i = 0; i < data.length; i++) {
                          line_entry_uri = data[i]['git_repo_root_uri'] + '/' + data[i]['entry'];
                          return '<table class="squish"><tr style="background-color:#F2F5A9;"><td style="width:150px;" align="left"><a href="' + line_entry_uri + '" target="_blank">' + data[i]['entry'] + '</a></td></tr></table>';

                        }
                      }
                    },
                    {
                      "data": "response",
                      "render": function (data, type, row, meta) {
                        return '<tr><td style="width:200px;" align="left">' + data + '</td>';
                      }
                    },
                    {
                      "data": "response_len",
                      "render": function (data, type, row, meta) {
                        return '<tr><td style="width:200px;" align="left">' + data + '</td>';
                      }
                    }
                  ]
                });
                // Toggle Columns
                $('a.toggle-vis').on('click', function (e) {
                  e.preventDefault();

                  // Get the column API object
                  var column = table.column( $(this).attr('data-column') );

                  // Toggle the visibility
                  column.visible( ! column.visible() );
                });

                // TODO: Open bug for selected rows ;)
                $('#button').click( function () {
                  alert($('#multi_line_select tr.selected').length +' row(s) selected');
                });
              });

              function multi_line_select() {
                // Select all lines in a row
                //$('#csi_fuzz_net_app_proto tbody').on('click', 'tr', function () {
                //  $(this).children('td').children('#multi_line_select').children('tbody').children('tr').toggleClass('selected');
                //});

              }
            </script>
          </body>
        </html>
        }

        File.open("#{dir_path}/csi_fuzz_net_app_proto.html", 'w') do |f|
          f.print(html_report)
        end
      rescue => e
        raise e.message
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
          #{self}.generate(
            dir_path: dir_path,
            results_hash: results_hash
          )

          #{self}.authors
        "
      end
    end
  end
end
