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
    },

  };

}(); // Geom


/* UI namespace */
var UI = function() {

  var cache_entity;
  var cache_transf;
  var cache_transf_info = null;
  var cache_result;
  var cache_result_info = null;

  // HTML tables are accessed in a row-major manner.
  // SketchUp's transformation matrices are column-major.
  // This lookup table maps row-index to column-index.
  var transpose_indices = [
    0, 4,  8, 12,
    1, 5,  9, 13,
    2, 6, 10, 14,
    3, 7, 11, 15,
  ]

  var kFloatEpsilon = 1e-6

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

      $cells.eq( 0).addClass( 'rotate scale x' ).attr( 'title', 'sX' );
      $cells.eq( 1).addClass( 'rotate scale y' );
      $cells.eq( 2).addClass( 'rotate scale z' );
      $cells.eq( 3).addClass( 'translation x' ).attr( 'title', 'Wx' );

      $cells.eq( 4).addClass( 'rotate scale x' );
      $cells.eq( 5).addClass( 'rotate scale y' ).attr( 'title', 'sY' );
      $cells.eq( 6).addClass( 'rotate scale z' );
      $cells.eq( 7).addClass( 'translation y' ).attr( 'title', 'Wy' );

      $cells.eq( 8).addClass( 'rotate scale x' );
      $cells.eq( 9).addClass( 'rotate scale y' );
      $cells.eq(10).addClass( 'rotate scale z' ).attr( 'title', 'sZ' );
      $cells.eq(11).addClass( 'translation z' ).attr( 'title', 'Wz' );

      $cells.eq(12).addClass( 'unused' );
      $cells.eq(13).addClass( 'unused' );
      $cells.eq(14).addClass( 'unused' );
      $cells.eq(15).addClass( 'scalar' ).attr( 'title', 'Wt' );

      for ( i = 0; i < 16; i++ ) {
        $cell = $cells.eq(i);
        // $cell.attr( 'title', $cell.attr('class') );
        var index = transpose_indices[i];
        // $cell.attr( 'data-matrix-index', 'Index: ' + index);
        // $cell.data( 'matrixIndex', 'Index: ' + index);
        //$cell[0].dataset.matrixIndex = index;
        // Due to IE bug:
        // https://stackoverflow.com/a/28031760/486990
        $cell[0].setAttribute('data-matrix-index', index);
      }
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

      $('#toggleMore').click( function() {
        $('.more').toggleClass('expand');
        var text = $('.more').hasClass('expand') ? 'Less' : 'More';
        $(this).text(text);
        window.location = 'skp:toggle_more';
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

    update_entity : function( klass, name, matrix, info ) {
      $('#entity .klass').text( klass );
      $('#entity .name').text( name );
      cache_entity = matrix;
      cache_transf = Geom.identity_transformation();
      cache_result = matrix;
      cache_transf_info = info;
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

    update_result_matrix : function( matrix, info ) {
      cache_result = matrix;
      cache_result_info = info;
      update_matrix( '#resultTransformation', cache_result );
      update_matrix_info( '#resultTransformation', cache_result_info );
    },

    reset : function() {
      $('#entity .klass').text('No Valid Selection');
      $('#entity .name').text('Select only one Group or Component');
      cache_entity = Geom.null_transformation();
      cache_transf = Geom.identity_transformation();
      cache_transf_info = null;
      cache_result = Geom.null_transformation();
      cache_result_info = null;
      cache_changed();
    }

  };

  function modify_matrix( element, cache ) {
    var $table = $( element ).parents( 'table' );
    var $inputs = $table.find( 'input' );
    var row_major_index = $inputs.index( element );
    var index = transpose_indices[row_major_index]; // column major index

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
    update_matrix_info( '#matrixEntity', cache_transf_info );
    update_matrix( '#matrixTransformation', cache_transf );
    update_matrix( '#resultTransformation', cache_result );
    update_matrix_info( '#resultTransformation', cache_result_info );
  }

  function float_eq(value1, value2) {
    return (value1 - value2) < kFloatEpsilon;
  }

  function format_float(value) {
    var formatted_value = parseFloat( value.toFixed(2) );
    var locale_value = formatted_value.toLocaleString();
    // Prepend with ~ to indicate number is truncated - ignoring floating point
    // noise.
    if (!float_eq(value, formatted_value)) {
      locale_value = '~' + locale_value;
    }
    return locale_value;
  }

  function update_matrix( table, matrix ) {
    var $cells = $(table).find('td input');
    for ( i = 0; i < 16; i++ ) {
      var index = transpose_indices[i];
      // Format value for output.
      var value = matrix[index];
      // Update matrix.
      $cells.eq(i).val( format_float(value) );
    }
  }

  function update_matrix_info( table, matrix_info ) {
    if (matrix_info === null) return;

    var $info = $(table).find('tfoot.info');

    $info.find('.x .rotation').text( format_float(matrix_info.rotation[0]) );
    $info.find('.y .rotation').text( format_float(matrix_info.rotation[1]) );
    $info.find('.z .rotation').text( format_float(matrix_info.rotation[2]) );

    $info.find('.x .scale').text( format_float(matrix_info.scale[0]) );
    $info.find('.y .scale').text( format_float(matrix_info.scale[1]) );
    $info.find('.z .scale').text( format_float(matrix_info.scale[2]) );
  }

}(); // UI

$(document).ready( UI.init );
