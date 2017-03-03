# frozen_string_literal: true
require 'json'

module CSI
  module Reports
    # This plugin generates the Static Code Anti-Pattern Matching Analysis
    # results within the root of a given source repo.  Two files are created,
    # a JSON file containing all of the SCAPM results and an HTML file
    # which is essentially the UI for the JSON file.
    module SCAPM
      # Supported Method Parameters::
      # CSI::Reports::SCAPM.generate(
      #   dir_path: dir_path,
      #   results_hash: results_hash
      # )

      public

      def self.generate(opts = {})
        dir_path = opts[:dir_path].to_s if File.directory?(opts[:dir_path].to_s)
        raise "CSI Error: Invalid Directory #{dir_path}" if dir_path.nil?
        results_hash = opts[:results_hash]

        # JSON object Completion
        File.open("#{dir_path}/csi_scan_git_source.json", 'w') do |f|
          f.print(results_hash.to_json)
        end

        # Report All the Bugs!!! \o/
        html_report = %q{<!DOCTYPE HTML>
        <html>
          <head>

            <link rel="stylesheet" href="//cdn.datatables.net/1.10.13/css/jquery.dataTables.min.css">
            <script src="//ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
            <script src="//cdn.datatables.net/1.10.13/js/jquery.dataTables.min.js"></script>
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
              <a class="toggle-vis" data-column="2" href="#">Test Case Invoked/NIST 800-53 Rev. 4 Section</a>&nbsp;|&nbsp;
              <a class="toggle-vis" data-column="3" href="#">Path</a>&nbsp;|&nbsp;
              <a class="toggle-vis" data-column="4" href="#">Line#, Formatted Content, &amp; Last Committed By</a>&nbsp;|&nbsp;
              <a class="toggle-vis" data-column="5" href="#">Raw Content</a>&nbsp;|&nbsp;
              <a class="toggle-vis" data-column="6" href="#">Test Case (Anti-Pattern) Filter</a>
            </div>
            <br /><br />

            <div>
              <table id="csi_scan_git_source_results" class="display" cellspacing="0">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Timestamp</th>
                    <th>Test Case Invoked/NIST 800-53 Rev. 4 Section</th>
                    <th>Path</th>
                    <th>Line#, Formatted Content, &amp; Last Committed By</th>
                    <th>Raw Content</th>
                    <th>Test Case (Anti-Pattern) Filter</th>
                  </tr>
                </thead>
                <!-- DataTables <tbody> -->
              </table>
            </div>

            <script>
              $.getJSON('csi_scan_git_source.json', function(json) {
                for (var i = 0; i < json['data'].length; i++) {
                  sp_zfn_results.insert( { data: json['data'][i] } );
                }
              });
              // For whatever reason, running console.log(sp_zfn_results.data) returns an empty array, however:
              console.log("To see the contents of the sp_zfn_results collection, run 'sp_zfn_results.data' from the console.");
              // will return the data inserted from the csi_scan_git_source.json file.

              var line_entry_uri = "";
              $(document).ready(function() {
                var oldStart = 0;
                var table = $('#csi_scan_git_source_results').DataTable( {
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
                  "ajax": "csi_scan_git_source.json",
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
                      "data": "test_case",
                      "render": function (data, type, row, meta) {
                        // convert camel-cased scapm modules to use underscore naming instead to ensure the test case can resolve to the proper csi github url in the report
                        return '<tr><td style="width:150px;" align="left"><a href="https://github.com/ninp0/csi/tree/master/lib/' + data['sp_module'].replace(/::/g, "/").toLowerCase() + '.rb" target="_blank">' + data['sp_module'].split("::")[2] + '</a><br /><a href="' + data['nist_800_53_uri'] + '" target="_blank">' + data['section']  + '</a></td></tr>';
                      }
                    },
                    {
                      "data": "filename",
                      "render": function (data, type, row, meta) {
                        for (var i = 0; i < data.length; i++) {
                          line_entry_uri = data[i]['git_repo_root_uri'] + '/' + data[i]['entry'];
                          return '<table class="squish"><tr style="background-color:#F2F5A9;"><td style="width:150px;" align="left"><a href="' + line_entry_uri + '" target="_blank">' + data[i]['entry'] + '</a></td></tr></table>';

                        }
                      }
                    },
                    {
                      "data": "line_no_and_contents",
                      "render": function (data, type, row, meta) {
                        var csi_rows = '<td style="width: 669px"><table id="multi_line_select" class="display squish" style="width: 665px"><tbody>';
                        for (var i = 0; i < data.length; i++) {
                          var tr_class;
                          if (i % 2 == 0) { tr_class = "odd"; } else { tr_class = "even"; }

                          //var filename_link = document.URL.substr(0,document.URL.lastIndexOf('/')) + '/' + row.filename;
                          var filename_link = row.filename;

                          var bug_comment = 'Timestamp: ' + row.timestamp + '\n' +
                                            'Test Case Invoked: http://' + window.location.hostname + ':8808/doc_root/csi-0.1.0/' +
                                              row.test_case['sp_module'].replace(/::/g, "/") + '\n' +
                                            'Source Code Impacted: ' + $("<div/>").html(filename_link).text() + '\n\n' +
                                            'Test Case Request:\n' +
                                            $("<div/>").html(row.test_case_filter.replace(/\s{2,}/g, " ")).text() + '\n\n' +
                                            'Test Case Response:\n' +
                                            '\tCommitted by: ' + $("<div/>").html(data[i]['author']).text() + '\t' +
                                              data[i]['line_no'] + ': ' +
                                              $("<div/>").html(data[i]['contents'].replace(/\s{2,}/g, " ")).text() + '\n\n';

                          var author_and_email_arr = data[i]['author'].split(" ");
                          var email = author_and_email_arr[author_and_email_arr.length - 1];
                          var email_user_arr = email.split("@");
                          var assigned_to = email_user_arr[0].replace("&lt;", "");

                          var uri = '#uri';

                         var canned_email_results = 'Timestamp: ' + row.timestamp + '\n' +
                                                    'Source Code File Impacted: ' + $("<div/>").html(filename_link).text() + '\n\n' +
                                                    'Source Code in Question:\n\n' +
                                                    data[i]['line_no'] + ': ' +
                                                    $("<div/>").html(data[i]['contents'].replace(/\s{2,}/g, " ")).text() + '\n\n';

                         var canned_email = email.replace("&lt;", "").replace("&gt;", "") + '?subject=Potential%20Bug%20within%20Source%20File:%20'+ encodeURIComponent(row.filename) +'&body=Greetings,%0A%0AThe%20following%20information%20likely%20represents%20a%20bug%20discovered%20through%20automated%20security%20testing%20initiatives:%0A%0A' + encodeURIComponent(canned_email_results) + 'Is%20this%20something%20that%20can%20be%20addressed%20immediately%20or%20would%20filing%20a%20bug%20be%20more%20appropriate?%20%20Please%20let%20us%20know%20at%20your%20earliest%20convenience%20to%20ensure%20we%20can%20meet%20security%20expectations%20for%20this%20release.%20%20Thanks%20and%20have%20a%20great%20day!';

                          to_line_number = line_entry_uri + '/#L' + data[i]['line_no'];
                          csi_rows = csi_rows.concat('<tr class="' + tr_class + '"><td style="width:90px" align="left"><a href="' + to_line_number + '" target="_blank">' + data[i]['line_no'] + '</a>:&nbsp;</td><td style="width:300px" align="left">' + data[i]['contents'] + '</td><td style="width:200px" align="right"><a href="mailto:' + canned_email + '">' + data[i]['author'] + '</a></td></tr>');
                        }
                        csi_rows = csi_rows.concat('</tbody></table></td>');
                        return csi_rows;
                      }
                    },
                    {
                      "data": "raw_content",
                      "render": function (data, type, row, meta) {
                        return '<tr><td style="width:200px;" align="left">' + data + '</td>';
                      }
                    },
                    {
                      "data": "test_case_filter",
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
                //$('#csi_scan_git_source_results tbody').on('click', 'tr', function () {
                //  $(this).children('td').children('#multi_line_select').children('tbody').children('tr').toggleClass('selected');
                //});

              }
            </script>
          </body>
        </html>
        }

        File.open("#{dir_path}/csi_scan_git_source.html", 'w') do |f|
          f.print(html_report)
        end
      rescue => e
        raise e.message
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public

      def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public

      def self.help
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
