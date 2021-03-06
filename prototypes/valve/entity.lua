

data:extend({
{
   type = "storage-tank",
   name = "overflow-valve",
   icon = "__overflow-valve__/graphics/icon/overflow-valve.png",
   flags = {"placeable-neutral", "player-creation"},
   minable = {hardness = 0.2, mining_time = 0.7, result = "overflow-valve"},
   max_health = 75,
   corpse = "small-remnants",
   collision_box = {{-0.29, -0.5}, {0.29, 0.5}},
   selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
   vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
   resistances = {{
	 type = "fire",
	 percent = 80
   }},
   fast_replaceable_group = "pipe",
   fluid_box = {
	 base_area = 1,
	 pipe_connections = {}
   },
   window_bounding_box = {{0,0}, {0,0}},
   working_sound = {
      sound = {{
	    filename = "__base__/sound/pipe.ogg",
	    volume = 0.85
      }},
      match_volume_to_activity = true,
      max_sounds_per_type = 3
   },

    pictures = {
       picture = {
	  sheet = {
	     filename = "__overflow-valve__/graphics/entity/overflow-valve/overflow-valve3.png",
	     priority = "extra-high",
	     frames = 2,
	     width = 44,
	     height = 49,
	     shift = {.2, 0}
	  }
       },
       fluid_background = {
	  filename = "__overflow-valve__/graphics/trans.png",
	  priority = "extra-high",
	  width = 1,
	  height = 1,
       },
       window_background = {
	  filename = "__overflow-valve__/graphics/trans.png",
	  priority = "extra-high",
	  width = 1,
	  height = 1,
       },
       flow_sprite = {
	  filename = "__overflow-valve__/graphics/trans.png",
	  priority = "extra-high",
	  width = 1,
	  height = 1,
       }
    },
    
    flow_length_in_ticks = 360,
    circuit_wire_connection_points = {
       {
	  shadow = {
	     red = {0, 0},
	     green = {0, 0},
	  },
	  wire = {
	     red = {0, 0},
	     green = {0, 0},
	  }
       },
       {
	  shadow = {
	     red = {0, 0},
	     green = {0, 0},
	  },
	  wire = {
	     red = {0, 0},
	     green = {0, 0},
	  }
       },
       {
	  shadow = {
	     red = {0, 0},
	     green = {0, 0},
	  },
	  wire = {
	     red = {0, 0},
	     green = {0, 0},
	  }
       },
       {
	  shadow = {
	     red = {0, 0},
	     green = {0, 0},
	  },
	  wire = {
	     red = {0, 0},
	     green = {0, 0},
	  }
       }
    },
    circuit_wire_max_distance = 0
},

{
   type = "storage-tank",
   name = "valve-proxy",
   icon = "__overflow-valve__/graphics/trans-icon.png",
   flags = {"placeable-neutral", "player-creation"},
   max_health = 1,
   corpse = "small-remnants",
   collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
   collision_mask = {},
   order = "z",
   fluid_box = {
	 base_area = 1,
	 pipe_covers = pipecoverspictures(),
	 pipe_connections = {
	    { position = {0, 1} }
	 }
   },
   window_bounding_box = {{0,0}, {0,0}},

    pictures = {
       picture = {
	  sheet = {
	     filename = "__overflow-valve__/graphics/trans.png",
	     priority = "extra-high",
	     frames = 1,
	     width = 1,
	     height = 1,
	     shift = {0, 0}
	  }
       },
       fluid_background = {
	  filename = "__overflow-valve__/graphics/trans.png",
	  priority = "extra-high",
	  width = 1,
	  height = 1,
       },
       window_background = {
	  filename = "__overflow-valve__/graphics/trans.png",
	  priority = "extra-high",
	  width = 1,
	  height = 1,
       },
       flow_sprite = {
	  filename = "__overflow-valve__/graphics/trans.png",
	  priority = "extra-high",
	  width = 1,
	  height = 1,
       }
    },
    
    flow_length_in_ticks = 360,
    circuit_wire_connection_points = {
       {
	  shadow = {
	     red = {0, 0},
	     green = {0, 0},
	  },
	  wire = {
	     red = {0, 0},
	     green = {0, 0},
	  }
       },
       {
	  shadow = {
	     red = {0, 0},
	     green = {0, 0},
	  },
	  wire = {
	     red = {0, 0},
	     green = {0, 0},
	  }
       },
       {
	  shadow = {
	     red = {0, 0},
	     green = {0, 0},
	  },
	  wire = {
	     red = {0, 0},
	     green = {0, 0},
	  }
       },
       {
	  shadow = {
	     red = {0, 0},
	     green = {0, 0},
	  },
	  wire = {
	     red = {0, 0},
	     green = {0, 0},
	  }
       }
    },
    circuit_wire_max_distance = 0
}})
