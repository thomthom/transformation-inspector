const testNodes = [
  {
    "id": 10500,
    "type": "PointsNode",
    "label": "Untitled",
    "position": [
      20.0,
      30.0
    ],
    "input": [

    ],
    "output": [
      {
        "id": 10520,
        "type": "OutputConnectionPoint",
        "channel_id": "geom",
        "node": 10500,
        "partners": [
          10460
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
    "position": [
      350.0,
      100.0
    ],
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
          10480
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
    "position": [
      600.0,
      100.0
    ],
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
    getNodeById: function(id) {
      return this.nodes.find(node => node.id == id)
    },
    nodeDragMouseDown: function(event) {
      event.preventDefault();
      document.onmousemove = this.nodeDrag;
      document.onmouseup = this.nodeEndDrag;

      const node_element = event.target.closest('section.node');
      const nodeId = node_element.dataset.nodeId;
      this.drag.node = this.getNodeById(nodeId);
    },
    nodeDrag: function(event) {
      let node = this.drag.node;
      node.position[0] = (node.position[0] + event.movementX);
      node.position[1] = (node.position[1] + event.movementY);
    },
    nodeEndDrag () {
      document.onmouseup = null;
      document.onmousemove = null;
    }
  },
}

Vue.createApp(NodeEditor).mount('#editor')
