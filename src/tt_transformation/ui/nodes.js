// @ts-check

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

class Point2d {
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }
};

class Rectangle {
  constructor(width, height) {
    this.width = width;
    this.height = height;
  }
};

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
    /**
     * @param {string} id
     */
    getCanvasById: function(id) {
      return /** @type{HTMLCanvasElement | null} */ (document.getElementById(id));
    },
    /** @return {HTMLCanvasElement | null} */
    getNodeCanvas: function() {
      return this.getCanvasById('canvasNodes');
    },
    resize_canvas: function() {
      const canvas = this.getNodeCanvas();
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      this.draw_node_connections();
    },
    draw_node_connections: function() {
      const canvas = this.getNodeCanvas();
      const ctx = canvas.getContext('2d');

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // ctx.fillStyle = '#0f02';
      // ctx.fillRect(0, 0, canvas.width, canvas.height);

      ctx.fillStyle = 'orange';
      ctx.strokeStyle = 'orange';
      ctx.lineWidth = 2;

      /** @type {NodeListOf<HTMLElement>} */
      const outputs = document.querySelectorAll('.node > .output > .connector');
      for (const output_element of outputs) {
        const outputId = parseInt(output_element.dataset.connectorId);
        const output = this.getConnectorById(outputId);
        for (const partner of output.partners) {
          // const input = this.getConnectorById(partner);
          const query = `[data-connector-id='${partner}']`;
          const input_element = document.querySelector(query);
          this.draw_node_connection(ctx, output_element, input_element);
        }
      }
    },
    draw_node_connection: function(ctx, output_element, input_element) {
      // TODO:
      // If you need the bounding rectangle relative to the top-left corner of
      // the document, just add the current scrolling position to the top and
      // left properties (these can be obtained using window.scrollX and
      // window.scrollY) to get a bounding rectangle which is independent from
      // the current scrolling position.
      const out_bounds = output_element.getBoundingClientRect();
      const out_x = out_bounds.right;
      const out_y = out_bounds.top + Math.round(out_bounds.height / 2);
      const out_pt = new Point2d(out_x, out_y);

      const in_bounds = input_element.getBoundingClientRect();
      const in_x = in_bounds.left;
      const in_y = in_bounds.top + Math.round(in_bounds.height / 2);
      const in_pt = new Point2d(in_x, in_y);

      // TODO: Use Path2d so we can check for points in a path/stroke.
      // https://developer.mozilla.org/en-US/docs/Web/API/Path2D/Path2D
      // https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/isPointInPath#checking_a_point_in_the_specified_path

      // console.log(
      //   'out x,y', out_x, out_y,
      //   'in x,y', in_x, in_y,
      // );

      // ctx.lineWidth = 1;
      // ctx.beginPath();
      // ctx.rect(out_bounds.left + 0.5, out_bounds.top + 0.5, out_bounds.width, out_bounds.height);
      // ctx.rect(in_bounds.left + 0.5, in_bounds.top + 0.5, in_bounds.width, in_bounds.height);
      // ctx.stroke();

      this.draw_connection(ctx, out_pt, in_pt);
    },
    /**
     * @param {CanvasRenderingContext2D} [ctx]
     * @param {Point2d} [pt1]
     * @param {Point2d} [pt2]
     */
    draw_connection: function(ctx, pt1, pt2, radius = 3, tension = 2) {
      const dx = Math.round((pt1.x - pt2.x) / tension);

      ctx.beginPath();
      ctx.moveTo(pt1.x, pt1.y);
      ctx.bezierCurveTo(
        pt1.x - dx, pt1.y,
        pt2.x + dx, pt2.y,
        pt2.x, pt2.y,
      );
      ctx.stroke();

      const angle = Math.PI * 2;
      ctx.beginPath();
      ctx.arc(pt1.x, pt1.y, radius, 0, angle);
      ctx.arc(pt2.x, pt2.y, radius, 0, angle);
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

    onNodeMove: function(nodeId, x, y) {
      // console.log('onNodeMove', nodeId, x, y);
      // TODO: Debounce this call? In case multiple nodes are updated in bulk.
      this.$nextTick(this.draw_node_connections);
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
      let x = (node.position.x + event.movementX);
      let y = (node.position.y + event.movementY);
      node.position.x = Math.max(0, x);
      node.position.y = Math.max(0, y);
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

const app = Vue.createApp(NodeEditor);

// Kludge! Ideally the whole node would be a component. But since
// we're not using single file components it's awkward to edit the template
// inline in a JS template string.
app.component('node-watcher', {
  props: ['node'],
  emits: ['move'],
  created() {
    this.$watch(
      () => this.node.position,
      (position) => { this.$emit('move', this.node.id, position.x, position.y); },
      { deep: true }
    );
  },
  template: `<section class="position"><b>Position:</b> {{ node.position.x }}, {{ node.position.y }}</section>`
});

const vm = app.mount('#editor');
