// @ts-check
// https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html

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
  /** @param {number} [x] */
  /** @param {number} [y] */
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }
  /**
   * @param {Point2d} point
   * @return {number} */
  distance(point) {
    return Math.sqrt((point.x - this.x)**2 + (point.y - this.y)**2);
  }
  /**
   * @param {Point2d} point
   * @return {boolean} */
  within_distance(point, distance) {
    return ((point.x - this.x)**2 + (point.y - this.y)**2) < distance**2;
  }
};

class Size {
  /** @param {number} [width] */
  /** @param {number} [height] */
  constructor(width, height) {
    this.width = width;
    this.height = height;
  }
};

/** @enum {number} */
const ConnectorType = {
  Input: 0,
  Output: 1,
};

// The Application
const NodeEditor = {
  data() {
    return {
      nodes: testNodes,
      drag: {
        node: undefined,
      },
      connectors: {
        input: new Map(),
        output: new Map(),
      },
      tool: {
        cursor: undefined,
        pick: undefined,
      },
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
    getToolCanvas: function() {
      return this.getCanvasById('canvasTools');
    },
    resizeCanvas: function() {
      const nodeCanvas = this.getNodeCanvas();
      nodeCanvas.width = window.innerWidth;
      nodeCanvas.height = window.innerHeight;

      const toolCanvas = this.getToolCanvas();
      toolCanvas.width = window.innerWidth;
      toolCanvas.height = window.innerHeight;

      this.drawNodeConnections();
      this.drawTool();
    },
    updateConnectors: function() {
      const outputs = this.getConnectorElements(ConnectorType.Output);
      this.connectors.output = this.computeConnectorPoints(outputs, ConnectorType.Output);

      const inputs = this.getConnectorElements(ConnectorType.Input);
      this.connectors.input = this.computeConnectorPoints(inputs, ConnectorType.Input);
    },
    /**
     * @param {MouseEvent} event
     */
    toolMove: function(event) {
      // console.log('mouse', event.x, event.y);
      this.tool.cursor = new Point2d(event.x, event.y);

      // Snap to connector points.
      const aperture = 8;
      const cursor = this.tool.cursor;
      let pick = undefined;
      for (const [id, pt] of this.connectors.input) {
        if (cursor.within_distance(pt, aperture)) {
          pick = { id: id, position: pt };
          break;
        }
      }
      if (pick === undefined) {
        for (const [id, pt] of this.connectors.output) {
          if (cursor.within_distance(pt, aperture)) {
            pick = { id: id, position: pt };
            break;
          }
        }
      }
      this.tool.pick = pick;

      this.drawTool();
    },
    drawTool: function() {
      const canvas = this.getToolCanvas();
      const ctx = canvas.getContext('2d');

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      const radius = 1.5;
      ctx.fillStyle = '#c00';
      for (const [_id, pt] of this.connectors.output) {
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, radius, 0, Math.PI * 2);
        ctx.fill();
      }
      for (const [_id, pt] of this.connectors.input) {
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, radius, 0, Math.PI * 2);
        ctx.fill();
      }

      let pt = this.tool.cursor;
      if (this.tool.pick) {
        pt = this.tool.pick.position;
      }
      if (pt) {
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, 3, 0, Math.PI * 2);
        ctx.fill();
      }
    },
    /**
     * @param {ConnectorType} type
     */
    getConnectorElements: function(type) {
      const typeStr = (type == ConnectorType.Input) ? 'input' : 'output';
      const query = `.node > .${typeStr} > .connector`;
      /** @type {NodeListOf<HTMLElement>} */
      const outputs = document.querySelectorAll(query);
      return outputs
    },
    /**
     * @param {NodeListOf<HTMLElement>} elements
     * @param {ConnectorType} type
     * @return {Map<number, Point2d>}
     */
    computeConnectorPoints: function(elements, type) {
      // TODO:
      // If you need the bounding rectangle relative to the top-left corner of
      // the document, just add the current scrolling position to the top and
      // left properties (these can be obtained using window.scrollX and
      // window.scrollY) to get a bounding rectangle which is independent from
      // the current scrolling position.
      //
      // TODO: Use Path2d so we can check for points in a path/stroke.
      // https://developer.mozilla.org/en-US/docs/Web/API/Path2D/Path2D
      // https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/isPointInPath#checking_a_point_in_the_specified_path
      let connections = new Map();
      for (const element of elements) {
        const nodeElement = element.closest('.node');
        const nodeBounds = nodeElement.getBoundingClientRect();

        const connectorId = parseInt(element.dataset.connectorId);
        const bounds = element.getBoundingClientRect();
        let position = new Point2d(0, 0);
        if (type == ConnectorType.Output) {
          position.x = nodeBounds.right - 1;
          position.y = bounds.top + Math.round(bounds.height / 2);
        } else {
          position.x = nodeBounds.left + 1;
          position.y = bounds.top + Math.round(bounds.height / 2);
        }
        connections.set(connectorId, position);
      }
      return connections;
    },
    drawNodeConnections: function() {
      const canvas = this.getNodeCanvas();
      const ctx = canvas.getContext('2d');

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // ctx.fillStyle = '#0f02';
      // ctx.fillRect(0, 0, canvas.width, canvas.height);

      const outputs = this.getConnectorElements(ConnectorType.Output);
      const outputPoints = this.connectors.output;
      this.drawConnectionPoints(ctx, outputPoints.values(), ConnectorType.Output);

      const inputPoints = this.connectors.input;
      this.drawConnectionPoints(ctx, inputPoints.values(), ConnectorType.Input);

      for (const output_element of outputs) {
        const outputId = parseInt(output_element.dataset.connectorId);
        const output = this.getConnectorById(outputId);
        const outPoint = outputPoints.get(outputId);
        for (const partner of output.partners) {
          const inPoint = inputPoints.get(partner);
          this.drawConnection(ctx, outPoint, inPoint);
        }
      }
    },
    /**
     * @param {CanvasRenderingContext2D} [ctx]
     * @param {Point2d} [pt1]
     * @param {Point2d} [pt2]
     */
    drawConnection: function(ctx, pt1, pt2, radius = 3, tension = 2) {
      const dx = Math.round((pt1.x - pt2.x) / tension);

      ctx.fillStyle = 'orange';
      ctx.strokeStyle = 'orange';
      ctx.lineWidth = 2;

      ctx.beginPath();
      ctx.moveTo(pt1.x, pt1.y);
      ctx.bezierCurveTo(
        pt1.x - dx, pt1.y,
        pt2.x + dx, pt2.y,
        pt2.x, pt2.y,
      );
      ctx.stroke();

      const circle = Math.PI * 2;
      ctx.beginPath();
      ctx.arc(pt1.x, pt1.y, radius, 0, circle);
      ctx.arc(pt2.x, pt2.y, radius, 0, circle);
      ctx.fill();
    },
    /**
     * @param {CanvasRenderingContext2D} ctx
     * @param {IterableIterator<Point2d>} points
     * @param {ConnectorType} type
     * @param {number} radius
     */
    drawConnectionPoints(ctx, points, type, radius = 6) {
      // Background
      const circle = Math.PI * 2;
      ctx.fillStyle = '#888'; // TODO: Get from .node CSS.
      // Border
      const startAngle = -Math.PI / 2;
      const endAngle = Math.PI / 2;
      const clockwise = type == ConnectorType.Input;
      ctx.lineWidth = 2;
      ctx.strokeStyle = '#000'; // TODO: Get from .node CSS.
      for (const pt of points) {
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, radius, startAngle, endAngle, clockwise);
        ctx.stroke();

        ctx.beginPath();
        ctx.arc(pt.x, pt.y, radius, 0, circle);
        ctx.fill();
      }
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
      // this.$nextTick(this.drawNodeConnections);
      this.$nextTick(function() {
        // console.log('nextTick');
        this.updateConnectors();
        this.drawNodeConnections();
        this.drawTool();
      });
    },

    nodeDragMouseDown: function(event) {
      event.preventDefault(); // Prevent native drag.
      document.addEventListener('mousemove', this.nodeDrag, { capture: true });
      document.addEventListener('mouseup', this.nodeEndDrag, { capture: true });

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
    nodeEndDrag: function() {
      document.removeEventListener('mousemove', this.nodeDrag, { capture: true });
      document.removeEventListener('mouseup ', this.nodeEndDrag, { capture: true });
    }
  },
  mounted() {
    this.updateConnectors();
    // TODO: Listen to viewport size change.
    this.resizeCanvas();
    document.addEventListener('mousemove', this.toolMove);
  },
}

const app = Vue.createApp(NodeEditor);

// Filters were removed in Vue3.
// Using this temporarily until node component is fleshed out and this can
// be replaced with a computed property.
// https://v3.vuejs.org/guide/migration/filters.html#migration-strategy
app.config.globalProperties.$filters = {
  nodeType(value) {
    return value.slice(0, value.lastIndexOf('Node'));
  }
}

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
  template: `
  <section class="position">
    <b>Position</b> {{ node.position.x }}, {{ node.position.y }}
  </section>
  `
});

const vm = app.mount('#editor');
