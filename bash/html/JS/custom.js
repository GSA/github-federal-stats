$(document).ready(function() {
    $('#example').dataTable( {
        "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
    } );


    $("#tabs").tabs( {

        "activate": function(event, ui) {

            $( $.fn.dataTable.tables( true ) ).DataTable().columns.adjust();

        }
 

} );


$(function() {
            $( "#tabs" ).tabs({
                ajaxOptions: {
                    error: function( xhr, status, index, anchor ) {
                        $( anchor.hash ).html(
                            "A problem occured." +
                            "There may be connection or server issues. Please try again." );
                    }
                }            
            });
        });

     

    $('table.display').dataTable( {
		
		 
        "scrollY": "350px",

        "scrollCollapse": true,

        "paging": true,

	 "pagingType": "simple_numbers",
		
	"lengthMenu": [[25, 50, 100, -1], [25, 50, 100, "All"]],


    } );

} );

