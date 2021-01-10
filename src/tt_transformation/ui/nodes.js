// Test data:
const testNodes = [
  {
    "id": 10500,
    "type": "PointsNode",
    "label": "Untitled",
    "position": {
      x: 20.0,
      y: 30.0
    },
    "input": [

    ],
    "output": [
      {
        "id": 10520,
        "type": "OutputConnectionPoint",
        "channel_id": "geom",
        "node": 10500,
        "partners": [
          10540
        ]
      }
    ],
    "config": {
      "points": [
        [
          0.0,
          0.0,
          0.0
        ],
        [
          9.0,
          0.0,
          0.0
        ],
        [
          9.0,
          9.0,
          0.0
        ],
        [
          0.0,
          9.0,
          0.0
        ]
      ]
    }
  },
  {
    "id": 10460,
    "type": "TransformationNode",
    "label": "Untitled",
    "position": {
      x: 350.0,
      y: 100.0
    },
    "input": [
      {
        "id": 10540,
        "type": "InputConnectionPoint",
        "channel_id": "geom",
        "node": 10460,
        "partner": 10520
      }
    ],
    "output": [
      {
        "id": 10560,
        "type": "OutputConnectionPoint",
        "channel_id": "geom",
        "node": 10460,
        "partners": [
          10600
        ]
      },
      {
        "id": 10580,
        "type": "OutputConnectionPoint",
        "channel_id": "transformation",
        "node": 10460,
        "partners": [

        ]
      }
    ],
    "config": {
      "transformation": [
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        2.0,
        0.0,
        0.0,
        0.0,
        0.0,
        3.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0
      ]
    }
  },
  {
    "id": 10480,
    "type": "TransformationNode",
    "label": "Untitled",
    "position": {
      x: 600.0,
      y: 100.0
    },
    "input": [
      {
        "id": 10600,
        "type": "InputConnectionPoint",
        "channel_id": "geom",
        "node": 10480,
        "partner": 10560
      }
    ],
    "output": [
      {
        "id": 10620,
        "type": "OutputConnectionPoint",
        "channel_id": "geom",
        "node": 10480,
        "partners": [

        ]
      },
      {
        "id": 10640,
        "type": "OutputConnectionPoint",
        "channel_id": "transformation",
        "node": 10480,
        "partners": [

        ]
      }
    ],
    "config": {
      "transformation": [
        -1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        -0.0,
        1.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0
      ]
    }
  }
];


// The Application
const NodeEditor = {
  data() {
    return {
      nodes: testNodes,
      drag: {
        node: undefined,
      }
    }
  },
  methods: {
    resize_canvas: function() {
      const canvas = document.getElementById('canvas');
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      this.draw_node_connections();
    },
    draw_node_connections: function() {
      const canvas = document.getElementById('canvas');
      const ctx = canvas.getContext('2d');

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // ctx.fillStyle = '#0f02';
      // ctx.fillRect(0, 0, canvas.width, canvas.height);

      ctx.fillStyle = 'orange';
      ctx.strokeStyle = 'orange';
      ctx.lineWidth = 2;

      const outputs = document.querySelectorAll('.node > .output > .connector');
      for (const output_element of outputs) {
        const outputId = parseInt(output_element.dataset.connectorId);
        const output = this.getConnectorById(outputId);
        // console.log('output', outputId)
        for (const partner of output.partners) {
          // console.log('  partner', partner);
          // const input = this.getConnectorById(partner);
          const query = `[data-connector-id='${partner}']`;
          const input_element = document.querySelector(query);
          // console.log('  input_element', input_element);
          this.draw_connection(ctx, output_element, input_element);
        }
      }
    },
    draw_connection: function(ctx, output_element, input_element) {
      // TODO:
      // If you need the bounding rectangle relative to the top-left corner of
      // the document, just add the current scrolling position to the top and
      // left properties (these can be obtained using window.scrollX and
      // window.scrollY) to get a bounding rectangle which is independent from
      // the current scrolling position.
      const out_bounds = output_element.getBoundingClientRect();
      const out_x = out_bounds.right;
      const out_y = out_bounds.top + Math.round(out_bounds.height / 2);

      const in_bounds = input_element.getBoundingClientRect();
      const in_x = in_bounds.left;
      const in_y = in_bounds.top + Math.round(in_bounds.height / 2);

      const dx = Math.round((out_x - in_x) / 2);

      // TODO: Use Path2d so we can check for points in a path/stroke.
      // https://developer.mozilla.org/en-US/docs/Web/API/Path2D/Path2D
      // https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/isPointInPath#checking_a_point_in_the_specified_path

      ctx.beginPath();
      ctx.moveTo(out_x, out_y);
      // ctx.lineTo(in_x, in_y);
      ctx.bezierCurveTo(
        out_x - dx, out_y,
        in_x + dx, in_y,
        in_x, in_y,
      );
      ctx.stroke();

      const radius = 3;
      const angle = Math.PI * 2;
      ctx.beginPath();
      ctx.arc(out_x, out_y, radius, 0, angle);
      ctx.arc(in_x, in_y, radius, 0, angle);
      ctx.fill();
    },

    getConnectorById: function(id) {
      let connector = undefined;
      for (const node of this.nodes) {
        connector = node.input.find(input => input.id == id);
        if (connector) break;

        connector = node.output.find(output => output.id == id);
        if (connector) break;
      }
      return connector;
    },
    getNodeById: function(id) {
      return this.nodes.find(node => node.id == id);
    },

    nodeDragMouseDown: function(event) {
      event.preventDefault();
      document.onmousemove = this.nodeDrag;
      document.onmouseup = this.nodeEndDrag;

      const node_element = event.target.closest('section.node');
      const nodeId = parseInt(node_element.dataset.nodeId);
      this.drag.node = this.getNodeById(nodeId);
    },
    nodeDrag: function(event) {
      let node = this.drag.node;
      // TODO: Prevent node from being moved to negative X and Y.
      node.position.x = (node.position.x + event.movementX);
      node.position.y = (node.position.y + event.movementY);
      this.draw_node_connections(); // TODO: Only redraw what changed
    },
    nodeEndDrag () {
      document.onmouseup = null;
      document.onmousemove = null;
    }
  },
  mounted() {
    // TODO: Listen to viewport size change.
    this.resize_canvas();
  },
}

Vue.createApp(NodeEditor).mount('#editor');
