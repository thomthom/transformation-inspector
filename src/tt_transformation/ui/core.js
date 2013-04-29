/* Geom namespace */
var Geom = function() {
  
  return {
  
    identity_transformation : function() {
      return [
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
      ];
    },
    
    null_transformation : function() {
      return [
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0
      ];
    }
  
  };
  
}(); // Geom


/* UI namespace */
var UI = function() {
  
  var cache_entity;
  var cache_transf;
  var cache_result;
  
  return {
  
    init : function() {
      // Ready Event
      UI.reset();
      UI.init_matrices();
      UI.init_matrix_events();
      UI.init_buttons();
      window.location = 'skp:Window_Ready';
    },
    
    init_matrix : function( table ) {
      var $cells = $(table).find('td');
      
      $cells.eq( 0).addClass( 'rotate scale' ).attr( 'title', 'sX' );
      $cells.eq( 1).addClass( 'rotate scale' );
      $cells.eq( 2).addClass( 'rotate scale' );
      $cells.eq( 3).addClass( 'unused' );
      
      $cells.eq( 4).addClass( 'rotate scale' );
      $cells.eq( 5).addClass( 'rotate scale' ).attr( 'title', 'sY' );
      $cells.eq( 6).addClass( 'rotate scale' );
      $cells.eq( 7).addClass( 'unused' );
      
      $cells.eq( 8).addClass( 'rotate scale' );
      $cells.eq( 9).addClass( 'rotate scale' );
      $cells.eq(10).addClass( 'rotate scale' ).attr( 'title', 'sZ' );
      $cells.eq(11).addClass( 'unused' );
      
      $cells.eq(12).addClass( 'translation' ).attr( 'title', 'Wx' );
      $cells.eq(13).addClass( 'translation' ).attr( 'title', 'Wy' );
      $cells.eq(14).addClass( 'translation' ).attr( 'title', 'Wz' );
      $cells.eq(15).addClass( 'translation' ).attr( 'title', 'Wt' );
      
      //for ( i = 0; i < 16; i++ ) {
      //  $cell = $cells.eq(i);
      //  $cell.attr( 'title', $cell.attr('class') );
      //}
    },
    
    init_buttons : function() {
      $('#resetEntity').click( function() {
        cache_transf = Geom.identity_transformation();
        cache_changed();
        update_sketchup_matrix();
      });
      
      $('#applyEntity').click( function() {
        cache_entity = cache_result;
        cache_transf = Geom.identity_transformation();
        cache_changed();
        update_sketchup_matrix();
      });
    },
    
    init_matrices : function() {
      $('table.matrix').each( function(index) {
        UI.init_matrix( $(this) );
      });
    },
    
    init_matrix_events : function() {
      $('#matrixEntity input').change( function() {
        modify_matrix( this, cache_entity );
        cache_changed();
      });
      
      $('#matrixTransformation input').change( function() {
        modify_matrix( this, cache_transf );
        cache_changed();
      });
    },
    
    update_entity : function( klass, name, matrix ) {
      $('#entity .klass').text( klass );
      $('#entity .name').text( name );
      cache_entity = matrix;
      cache_transf = Geom.identity_transformation();
      cache_result = matrix;
      cache_changed();
    },
    
    update_entity_matrix : function( matrix ) {
      cache_entity = matrix;
      cache_changed();
    },
    
    update_transformation_matrix : function( matrix ) {
      cache_transf = matrix;
      cache_changed();
    },
    
    update_result_matrix : function( matrix ) {
      cache_result = matrix;
      update_matrix( '#resultTransformation', cache_result );
    },
    
    reset : function() {
      $('#entity .klass').text('No Valid Selection');
      $('#entity .name').text('Select only one Group or Component');
      cache_entity = Geom.null_transformation();
      cache_transf = Geom.identity_transformation();
      cache_result = Geom.null_transformation();
      cache_changed();
    }
  
  };
  
  function modify_matrix( element, cache ) {
    var $table = $( element ).parents( 'table' );
    var $inputs = $table.find( 'input' );
    var index = $inputs.index( element );
    
    var value = parseFloat( $(element).val().replace(',', '.') );
    
    cache[ index ] = value;
    
    update_sketchup_matrix();
    
    //var entity_matrix = '[' + cache_entity + ']';
    //var transf_matrix = '[' + cache_transf + ']';
    //window.location = 'skp:update_transformation@' + entity_matrix + '||' + transf_matrix;
  }
  
  function update_sketchup_matrix() {
    var entity_matrix = '[' + cache_entity + ']';
    var transf_matrix = '[' + cache_transf + ']';
    window.location = 'skp:update_transformation@' + entity_matrix + '||' + transf_matrix;
  }
  
  function cache_changed() {
    update_matrix( '#matrixEntity', cache_entity );
    update_matrix( '#matrixTransformation', cache_transf );
    update_matrix( '#resultTransformation', cache_result );
  }
  
  function update_matrix( table, matrix ) {
    var $cells = $(table).find('td input');
    for ( i = 0; i < 16; i++ ) {
      // Format value for output.
      value = matrix[i];
      formatted_value = parseFloat( value.toFixed(2) );
      locale_value = formatted_value.toLocaleString();
      if ( value != formatted_value ) {
        locale_value = '~' + locale_value;
      }
      // Update matrix.
      $cells.eq(i).val( locale_value );
    }
  }
  
}(); // UI

$(document).ready( UI.init );