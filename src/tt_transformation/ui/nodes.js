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
      },
      {
        "id": 11540,
        "type": "InputConnectionPoint",
        "channel_id": "transformation",
        "node": 10460,
        "partner": null
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
      },
      {
        "id": 11600,
        "type": "InputConnectionPoint",
        "channel_id": "transformation",
        "node": 10480,
        "partner": null
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
  },
  {
    "id": 1860,
    "type": "TransformationNode",
    "label": "Untitled",
    "position": {
      "x": 350.0,
      "y": 400.0
    },
    "input": [
      {
        "id": 1880,
        "type": "InputConnectionPoint",
        "channel_id": "geom",
        "node": 1860,
        "partner": null
      },
      {
        "id": 1900,
        "type": "InputConnectionPoint",
        "channel_id": "transformation",
        "node": 1860,
        "partner": null
      }
    ],
    "output": [
      {
        "id": 1920,
        "type": "OutputConnectionPoint",
        "channel_id": "geom",
        "node": 1860,
        "partners": [

        ]
      },
      {
        "id": 1940,
        "type": "OutputConnectionPoint",
        "channel_id": "transformation",
        "node": 1860,
        "partners": [

        ]
      }
    ],
    "config": {
      "transformation": [
        0.8660254037844386,
        0.5,
        0.0,
        0.0,
        -0.5,
        0.8660254037844386,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0
      ]
    }
  },
  {
    "id": 600,
    "type": "DrawPointsNode",
    "label": "Untitled",
    "position": {
      "x": 896.0,
      "y": 88.0
    },
    "input": [
      {
        "id": 620,
        "type": "InputConnectionPoint",
        "channel_id": "geom",
        "node": 600,
        "partner": null
      }
    ],
    "output": [

    ],
    "config": {
      "mode": 2,
      "color": [
        255,
        165,
        0,
        255
      ],
      "line_width": 2,
      "stipple": ""
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
  /**
   * @return [Array]
   */
  to_a() {
    return [this.x, this.y];
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

class NodeSocket {
  /** @param {ConnectorType} [type] */
  /** @param {any} [connector] */
  /** @param {Point2d} [position] */
  constructor(type, connector, position) {
    this.type = type;
    this.connector = connector;
    this.position = position;
    this.editing = false;
  }
};

let defaultNodes = [];
const isSketchUp = typeof sketchup !== 'undefined';
if (!isSketchUp) {
  console.info('Not running in context of SketchUp; loading test data...');
  defaultNodes = testNodes;
}

const DrawModeNames = [
  { value: 0, label: 'GL_POINTS' },
  { value: 1, label: 'GL_LINES' },
  { value: 2, label: 'GL_LINE_LOOP' },
  { value: 3, label: 'GL_LINE_STRIP' },
  { value: 4, label: 'GL_TRIANGLES' },
  { value: 5, label: 'GL_TRIANGLE_STRIP' },
  { value: 6, label: 'GL_TRIANGLE_FAN' },
  { value: 7, label: 'GL_QUADS' },
  { value: 8, label: 'GL_QUAD_STRIP' },
  { value: 9, label: 'GL_POLYGON' },
];

const StippleNames = [
  { value: '', label: 'Solid' },
  { value: '.', label: 'Dotted' },
  { value: '-', label: 'Short Dash' },
  { value: '_', label: 'Long Dash' },
  { value: '-.-', label: 'Dash Dot Dash' },
];

const PointStyleNames = [
  { value: 1, label: 'Open Square' },
  { value: 2, label: 'Filled Square' },
  { value: 3, label: 'Plus' },
  { value: 4, label: 'Cross' },
  { value: 5, label: 'Star' },
  { value: 6, label: 'Open Triangle' },
  { value: 7, label: 'Filled Triangle' },
];

// The Application
const NodeEditor = {
  data() {
    return {
      nodeTypes: [
        { id: 'PointsNode', label: "Points" },
        { id: 'TransformationNode', label: "Transformation" },
      ],
      nodes: defaultNodes,
      updating: false,
      drag: {
        node: undefined,
      },
      connectors: { // TODO: Rename to sockets
        input: new Map(), // Map<number, NodeSocket>
        output: new Map(), // Map<number, NodeSocket>
      },
      tool: {
        cursor: undefined, // Point2d
        pick: undefined, // NodeSocket | null
        startPick: undefined, // NodeSocket | null
        // Existing socket connection being edited.
        // input: NodeSocket
        // output: NodeSocket
        editing: { input: undefined, output: undefined },
      },
    }
  },
  methods: {
    newNode: function(item) {
      if (isSketchUp) {
        console.log('sketchup.new_node', item.id);
        sketchup.new_node(item.id);
      } else {
        console.info('TODO: new node:', item.id);
      }
    },
    /**
     * @param {number} inputId Connector id
     * @param {number} outputId Connector id
     */
    connect: function(inputId, outputId) {
      if (isSketchUp) {
        console.log('sketchup.connect', inputId, outputId);
        sketchup.connect(inputId, outputId);
      } else {
        const input = this.getConnectorById(inputId);
        const output = this.getConnectorById(outputId);
        // console.log('input', input);
        // console.log('output', output);
        input.partner = output.id;
        output.partners.push(input.id);
        this.$nextTick(function() { // TODO: do automatically.
          this.updateConnectors();
          this.drawNodeConnections();
        });
      }
    },
    /**
     * @param {number} inputId Connector id
     * @param {number} outputId Connector id
     */
    disconnect: function(inputId, outputId) {
      if (isSketchUp) {
        console.log('sketchup.disconnect', inputId, outputId);
        sketchup.disconnect(inputId, outputId);
      } else {
        const input = this.getConnectorById(inputId);
        const output = this.getConnectorById(outputId);
        // console.log('input', input);
        // console.log('output', output);

        input.partner = null;

        const i = output.partners.lastIndexOf(input.id);
        if (i !== -1) {
          output.partners.splice(i, 1);
        }
        // output.partners.delete(input.id);

        this.$nextTick(function() { // TODO: do automatically.
          this.updateConnectors();
          this.drawNodeConnections();
        });
      }
    },
    sync_position: function(node) {
      if (this.updating) return;
      if (isSketchUp) {
        console.log('sketchup.sync_position', node.id, node.position);
        sketchup.sync_position(node.id, [node.position.x, node.position.y]);
      }
    },
    sync_transformation: function(nodeId, transformation) {
      // console.log('sketchup.sync_transformation', nodeId);
      // console.log('arguments', arguments);
      if (this.updating) return;
      if (isSketchUp) {
        console.log('sketchup.sync_transformation', nodeId);
        const values = Object.values(transformation);
        sketchup.sync_transformation(nodeId, values);
      }
    },
    sync_draw_mode: function(nodeId, mode) {
      // console.log('sketchup.sync_draw_mode', nodeId, mode);
      // console.log('arguments', arguments);
      if (this.updating) return;
      if (isSketchUp) {
        console.log('sketchup.sync_draw_mode', nodeId, mode);
        sketchup.sync_draw_mode(nodeId, mode);
      }
    },
    sync_line_stipple: function(nodeId, stipple) {
      // console.log('sketchup.sync_line_stipple', nodeId, stipple);
      // console.log('arguments', arguments);
      if (this.updating) return;
      if (isSketchUp) {
        console.log('sketchup.sync_line_stipple', nodeId, stipple);
        sketchup.sync_line_stipple(nodeId, stipple);
      }
    },
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
      console.log('resizeCanvas');
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
     * @param {Point2d} point
     * @return {NodeSocket | null}
     */
    toolPickConnector(point) {
      const aperture = 8;
      for (const [id, socket] of this.connectors.input) {
        if (point.within_distance(socket.position, aperture)) {
          return socket;
        }
      }
      for (const [id, socket] of this.connectors.output) {
        if (point.within_distance(socket.position, aperture)) {
          return socket;
        }
      }
      return null;
    },
    toolIsPickValid() {
      if (!this.tool.startPick) {
        return false;
      }
      if (!this.tool.pick) {
        return false;
      }
      const startPick = this.tool.startPick;
      const pick = this.tool.pick;

      // Connect Input to Output and vice-versa.
      const type = (startPick.type == ConnectorType.Input) ? ConnectorType.Output : ConnectorType.Input;
      if (pick.type != type) {
        return false;
      }

      // Connect to compatible Channel ID.
      const channelId = startPick.connector.channel_id;
      if (pick.connector.channel_id != channelId) {
        return false;
      }

      // Don't connect to itself.
      const node = startPick.connector.node;
      if (pick.connector.node == node) {
        return false;
      }

      // Don't connect multiple outputs to an input.
      if (startPick.type == ConnectorType.Output) {
        if (pick.connector.partner) {
          return false;
        }
      }

      // Don't connect into a recursive loop.
      // TODO: ...
      return true;
    },
    /**
     * @param {MouseEvent} event
     */
    toolMouseDown: function(event) {
      // console.log('toolMouseDown', event.x, event.y);
      if (this.tool.pick) {
        event.preventDefault();
        this.tool.startPick = this.tool.pick;

        // TODO: Check if existing connection was picked.
        if (this.tool.startPick.connector.type == 'InputConnectionPoint') {
          const inputSocket = this.tool.pick;

          const outputId = inputSocket.connector.partner;
          const outputSocket = this.getSocketById(outputId);
          if (outputSocket) {
            inputSocket.editing = true;
            this.tool.startPick = outputSocket;
            this.tool.editing.input = inputSocket;
            this.tool.editing.output = outputSocket;
            this.drawNodeConnections();
          }
        }

        this.drawTool();
      }
    },
    /**
     * @param {MouseEvent} event
     */
    toolMouseUp: function(event) {
      // console.log('toolMouseUp', event.x, event.y);
      if (this.tool.editing.input) {
        if (!this.tool.pick) {
          const connector1 = this.tool.editing.input.connector;
          const connector2 = this.tool.editing.output.connector;

          console.log(`Disconnect node ${connector1.node}:${connector1.id} to node ${connector2.node}:${connector2.id}`);
          this.disconnect(connector1.id, connector2.id);
        }
        this.tool.editing.input.editing = false;
        this.tool.editing.input = undefined;
        this.drawNodeConnections();
      }
      if (this.tool.startPick && this.toolIsPickValid()) {
        let sockets = [this.tool.startPick, this.tool.pick];
        if (sockets[0].type == ConnectorType.Output) {
          sockets.reverse();
        }

        const connector1 = sockets[0].connector;
        const connector2 = sockets[1].connector;

        console.log(`Connect node ${connector1.node}:${connector1.id} to node ${connector2.node}:${connector2.id}`);
        this.connect(connector1.id, connector2.id);
      }
      this.tool.startPick = undefined;
      this.drawTool();
    },
    /**
     * @param {MouseEvent} event
     */
    toolMouseMove: function(event) {
      // console.log('toolMouseMove', event.x, event.y);
      this.tool.cursor = new Point2d(event.x, event.y);
      this.tool.pick = this.toolPickConnector(this.tool.cursor );
      this.drawTool();
    },
    drawTool: function() {
      const canvas = this.getToolCanvas();
      const ctx = canvas.getContext('2d');

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      /* DEBUG
      const radius = 1.5;
      ctx.fillStyle = '#c00';
      for (const [_id, socket] of this.connectors.output) {
        const pt = socket.position;
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, radius, 0, Math.PI * 2);
        ctx.fill();
      }
      for (const [_id, socket] of this.connectors.input) {
        const pt = socket.position;
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
      */

      const radius = 1.5;
      ctx.fillStyle = '#fff';
      if (this.tool.pick) {
        const pt = this.tool.pick.position;
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, 3, 0, Math.PI * 2);
        ctx.fill();
      }

      if (this.tool.startPick) {
        const startPick = this.tool.startPick;
        const pick = this.tool.pick;
        let dash = [2, 2]; // Dashed (Not connected)
        let point = this.tool.cursor;
        let color = '#fff';
        if (pick) {
          point = pick.position;
          dash = []; // Solid (Connected)
          // Only display warning color if the connection pick has an input and
          // and output.
          if (!pick.editing && startPick.connector.id != pick.connector.id && !this.toolIsPickValid()) {
            color = '#c00';
          } else {
          }
        }

        ctx.fillStyle = color;
        ctx.strokeStyle = color;
        ctx.setLineDash(dash);

        this.drawConnection(ctx, this.tool.startPick.position, point);
      }
    },
    getSocketById: function(id) {
      return this.connectors.input.get(id) || this.connectors.output.get(id);
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
     * @return {Map<number, NodeSocket>}
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
      /** @type {Map<number,NodeSocket>} */
      let connections = new Map();
      for (const element of elements) {
        const nodeElement = element.closest('.node');
        const nodeBounds = nodeElement.getBoundingClientRect();

        const connectorId = parseInt(element.dataset.connectorId);
        const connector = this.getConnectorById(connectorId);
        const bounds = element.getBoundingClientRect();
        let position = new Point2d(0, 0);
        if (type == ConnectorType.Output) {
          position.x = nodeBounds.right - 1;
          position.y = bounds.top + Math.round(bounds.height / 2);
        } else {
          position.x = nodeBounds.left + 1;
          position.y = bounds.top + Math.round(bounds.height / 2);
        }
        let socket = new NodeSocket(type, connector, position);
        connections.set(connectorId, socket);
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
      const outputConnections = this.connectors.output;
      const outputPoints = Array.from(outputConnections).map(socket => socket[1].position);
      this.drawConnectionPoints(ctx, outputPoints, ConnectorType.Output);

      const inputConnections = this.connectors.input;
      const inputPoints = Array.from(inputConnections).map(socket => socket[1].position);
      this.drawConnectionPoints(ctx, inputPoints, ConnectorType.Input);

      ctx.fillStyle = 'orange';
      ctx.strokeStyle = 'orange';
      for (const output_element of outputs) {
        const outputId = parseInt(output_element.dataset.connectorId);
        const output = this.getConnectorById(outputId);
        const outPoint = outputConnections.get(outputId).position;
        for (const partner of output.partners) {
          const inputSocket = inputConnections.get(partner);
          if (inputSocket.editing) {
            console.log('Editing connection...')
            ctx.fillStyle = '#222';
            ctx.strokeStyle = '#222';
            ctx.setLineDash([2, 2]);
          } else {
            ctx.fillStyle = 'orange';
            ctx.strokeStyle = 'orange';
            ctx.setLineDash([]);
          }
          this.drawConnection(ctx, outPoint, inputSocket.position);
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
     * @param {Array<Point2d>} points
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
      console.log('nodeDragMouseDown');
      event.preventDefault(); // Prevent native drag.
      document.addEventListener('mousemove', this.nodeDrag, { capture: true });
      document.addEventListener('mouseup', this.nodeEndDrag, { capture: true, once: true });

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
      console.log('nodeEndDrag');
      document.removeEventListener('mousemove', this.nodeDrag, { capture: true });
      // document.removeEventListener('mouseup ', this.nodeEndDrag, { capture: true });
      this.sync_position(this.drag.node);
      this.drag.node = undefined;
    }
  },
  mounted() {
    this.updateConnectors();
    this.resizeCanvas();
    window.addEventListener('resize', this.resizeCanvas);
    document.addEventListener('mousemove', this.toolMouseMove);
    document.addEventListener('mousedown', this.toolMouseDown);
    document.addEventListener('mouseup', this.toolMouseUp);

    if (isSketchUp) {
      console.log('sketchup.ready');
      sketchup.ready();
    }
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
  <section class="node-watcher">
    <b>Position</b> {{ node.position.x }}, {{ node.position.y }}
  </section>
  `
});

app.component('TransformationNode', {
  // Trying to bind nodeId will end up passing `undefined` to the receive of
  // the emitted event even though the handler can access the value correctly.
  // Renaming it to simply `node` and it works just fine. (??)
  props: ['node', 'config'],
  emits: ['sync_transformation'],
  computed: {
    matrix() {
      return this.config.transformation;
    },
  },
  watch: {
    matrix: {
      deep: true,
      handler(newMatrix) {
        this.$emit('sync_transformation', this.node, newMatrix);
      }
    }
  },
  template: `
  <div>
    <table class="node-matrix-4x4">

    <colgroup>
      <col width="25%">
      <col width="25%">
      <col width="25%">
      <col width="25%">
    </colgroup>

    <tbody>
      <tr>
        <td><input class="rotate scale x" title="sX" v-model.number="matrix[0]" /></td>
        <td><input class="rotate scale y" title="" v-model.number="matrix[4]" /></td>
        <td><input class="rotate scale z" title="" v-model.number="matrix[8]" /></td>
        <td><input class="translation x" title="Wx" v-model.number="matrix[12]" /></td>
      </tr>

      <tr>
        <td><input class="rotate scale x" title="" v-model.number="matrix[1]" /></td>
        <td><input class="rotate scale y" title="sY" v-model.number="matrix[5]" /></td>
        <td><input class="rotate scale z" title="" v-model.number="matrix[9]" /></td>
        <td><input class="translation y" title="Wy" v-model.number="matrix[13]" /></td>
      </tr>

      <tr>
        <td><input class="rotate scale x" title="" v-model.number="matrix[2]" /></td>
        <td><input class="rotate scale y" title="" v-model.number="matrix[6]" /></td>
        <td><input class="rotate scale z" title="sZ" v-model.number="matrix[10]" /></td>
        <td><input class="translation z" title="Wz" v-model.number="matrix[14]" /></td>
      </tr>

      <tr>
        <td><input class="unused" title="" v-model.number="matrix[3]" /></td>
        <td><input class="unused" title="" v-model.number="matrix[7]" /></td>
        <td><input class="unused" title="" v-model.number="matrix[11]" /></td>
        <td><input class="scalar" title="Wt" v-model.number="matrix[15]" /></td>
      </tr>
    </tbody>

    </table>
  </div>
  `
});

app.component('PointsNode', {
  props: ['config'],
  template: `
  <div>
    Points: {{ config.points.length }}
  </div>
  `
});

app.component('DrawPointsNode', {
  props: ['node', 'config'],
  data() {
    return {
      drawModeOptions: DrawModeNames,
      stippleOptions: StippleNames,
    }
  },
  computed: {
    color() {
      // TODO: Return Color type with named accessors?
      return this.config.color;
    },
    formattedColor() {
      return `${this.color[0]}, ${this.color[1]}, ${this.color[2]}, ${this.color[3]}`;
    },
    cssColor() {
      return `rgb(${this.color[0]}, ${this.color[1]}, ${this.color[2]})`;
    },
  },
  methods: {
    onDrawModeChange() {
      this.$emit('sync_draw_mode', this.node, this.config.mode);
    },
    onLineStippleChange() {
      this.$emit('sync_line_stipple', this.node, this.config.stipple);
    },
  },
  template: `
  <div>
    <div>Mode:
      <select v-model="config.mode" @change="onDrawModeChange">
        <option v-for="option in drawModeOptions" :value="option.value">
          {{ option.label }}
        </option>
      </select>
    </div>
    <div>
      Color:
      <span class="node-color" :style="{ background: cssColor }"></span>
      {{ formattedColor }}
    </div>
    <div>Line Width: {{ config.line_width }}</div>
    <div>Line Stipple:
      <select v-model="config.stipple" @change="onLineStippleChange">
        <option v-for="option in stippleOptions" :value="option.value">
          {{ option.label }}
        </option>
      </select>
    </div>
  </div>
  `
});

app.component('toolbar-button-dropdown', {
  props: ['items'],
  emits: ['select'],
  data() {
    return { menu: false }
  },
  methods: {
    select(item) {
      console.log('select item:', item);
      this.menu = false;
      this.$emit('select', item);
    },
    mouseCapture(event) {
      console.log('mouseCapture');
      // console.log('target', event.target);
      this.menu = false;
    }
  },
  watch: {
    menu(show) {
      if (show) {
        const board = document.getElementsByClassName('node-board')[0];
        board.addEventListener('mousedown', this.mouseCapture, {
          once: true,
          passive: true,
        });
      }
    }
  },
  template: `
  <div class="node-toolbar-item">
    <button @click="menu = !menu"><slot></slot></button>
    <div v-show="menu" class="node-toolbar-dropdown">
      <div v-for="item in items" :key="item.id" @click="select(item)">{{ item.label }}</div>
    </div>
  </div>
  `
});

const vm = app.mount('#editor');

function updateNodes(nodes) {
  console.log('updateNodes', nodes);
  vm.updating = true;
  vm.nodes = nodes;
  // vm.updating = false;
  console.log('> updateNodes', nodes);
  // TODO: Do this automatically when nodes changes.
  vm.$nextTick(function() {
    // console.log('nextTick');
    vm.updateConnectors();
    vm.drawNodeConnections();
    // vm.drawTool();
    vm.updating = false;
  });
}

function updateNodeTypes(nodeTypes) {
  console.log('updateNodeTypes', nodeTypes);
  vm.nodeTypes = nodeTypes;
}
