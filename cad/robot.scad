$fn = 40;

module rounded_cube(size=[1, 1, 1], r=3) {
  x = size[0];
  y = size[1];
  z = size[2];

  hull() {
    translate([+x/2-r, +y/2-r, 0]) cylinder(r=r, h=z, center=true);
    translate([+x/2-r, -y/2+r, 0]) cylinder(r=r, h=z, center=true);
    translate([-x/2+r, +y/2-r, 0]) cylinder(r=r, h=z, center=true);
    translate([-x/2+r, -y/2+r, 0]) cylinder(r=r, h=z, center=true);
  }
};

module motor(h=2) {
  r = 28.0 / 2;
  
  rotate([0, 90, 0]) union() {
    cylinder(r=r, h=20, center=true);
    translate([r, 0, 0]) cube([5, 15, 20], center=true);
    translate([r + 5/2, 0, 0]) cube([5, 15, 20], center=true);
    
  }
  
  translate([10-h, +35.0/2, 0]) rotate([0, 90, 0]) cylinder(r=1.5, h=h);
  translate([10-h, -35.0/2, 0]) rotate([0, 90, 0]) cylinder(r=1.5, h=h);
};

module camera_holes(r=1.0, h=1) {
  translate([+21/2, -h/2+0.5, 0]) rotate([90, 0, 0]) cylinder(r=r, h=h+1, center=true);
  translate([-21/2, -h/2+0.5, 0]) rotate([90, 0, 0]) cylinder(r=r, h=h+1, center=true);
};



module driver_holes(r=2.6/2, h=10) {
  for(x = [-31/2., +31/2]) for (y = [-26/2, +26/2]) {
    translate([x, y, 0]) cylinder(r=r, h=h, center=true);
  }
};
module main_board() {
  h1 = 6;
  h2 = 3;
  difference() {
    union() {
      difference() {
        rounded_cube([100, 80, h1  ]);
      };
    }
    
    # mirror([0, 0, 0]) translate([+40.5, 0, 0]) motor(); // left motor
    # mirror([1, 0, 0]) translate([+40.5, 0, 0]) motor(); // right motor
    
    for(y=[-20, +20]) translate([0, y, 0]) {
      driver_holes();
      rounded_cube([25, 27, h1+1], r=1.5);
    }
    
    # translate([0, 40-1.5+0.5, 0]) cube([17, 3+1, h1+1], center=true);
    # translate([0, 80/2, 0]) camera_holes(); // camera holes

    for (x = [-36, 36]) for (y = [-34, 34]) {
      translate([x, y, 0]) union() {
        cylinder(r=1.5, h=10, center=true);
        translate([0, 0, -h1/2+h2]) cylinder(r=4, h=h1+1);
      }
    }
    union() {
      cylinder(r=1.5, h=10, center=true);
      translate([0, 0, -h1/2+h2]) cylinder(r=4, h=h1+1);
    }
  };
};


module rpi0_holes(r=2.6/2, h=10) {
  translate([+58/2, +23/2, 0]) cylinder(r=r, h=h, center=true);
  translate([+58/2, -23/2, 0]) cylinder(r=r, h=h, center=true);
  translate([-58/2, +23/2, 0]) cylinder(r=r, h=h, center=true);
  translate([-58/2, -23/2, 0]) cylinder(r=r, h=h, center=true);
}

module controller_board() {
  h = 3;
  difference() {
    rounded_cube([80, 80, h]);
    
    // holes for fixing [todo]
    translate([  0, 0, 0]) cylinder(r=1.5, h=4, center=true);
    for (x = [-36, 36]) translate([x, -34, 0]) cylinder(r=1.5, h=10, center=true);
    
    // rpi0 holes
    translate([0, -25, 0]) {
      rpi0_holes();
      cube([50, 30, h+1], center=true);
    }
    
    translate([0, 24, 0]) {
      r = 3 / 2;

      translate([-51.5/2, -21/2, 0]) cylinder(r=r, h=10, center=true);
      translate([+51.5/2, +21/2, 0]) cylinder(r=r, h=10, center=true);

      # translate([ +30, 0, 1]) cube([4, 14, h-1+1], center=true);  // hole for audio port
      # translate([ -30, 0, 1]) cube([4, 14, h-1+1], center=true);    // hole for usb port
      # translate([-2.5, 11.5, 1]) cube([10, 4, h-1+1], center=true);  // hole for OSC
      # translate([+25.5, 0, 1]) cube([5, 5, h-1+1], center=true);  // hole for OSC
      
      rounded_cube([40, 15, h+1], center=true);
    }
    
    // mic holes
    for (m = [-1, 1]) mirror ([(m + 1) / 2, 0, 0]) translate([37.5, 20, 0]){
      w = 6.5;
      translate([-0.5, 0, 0]) cube([1, w, h+1], center=true);
      translate([0, 0, 1]) cube([5, w, h-1+1], center=true);
      
      translate([1.25, 0, 0]) cube([2.5, w-0.6*2, h+1], center=true);
    }
    
    translate([+15, 0, 0]) rounded_cube([20, 6, h+1], center=true);
    // translate([  0, -25, 0]) rounded_cube([50, 30, h+1], center=true);
  }
};

module btch_holes(r=3/2., h=10) {
  x = 0;
  for(x = [-44.5/2, +44.5/2]) for(y = [-63/2, +63/2]) {
    translate([x, y, 0]) cylinder(r=r, h=h, center=true);
  }
}
module battery_board() {
  h = 3;
  difference() {
    rounded_cube([80, 80, h]);
    
    translate([0, 6, 0]) btch_holes();
    # translate([0, -20.5, (h - 2) / 2 + 0.5/2]) cube([38, 15, 2+0.5], center=true); 
    # translate([0, -34, 0]) cube([38, 12, h+1], center=true); 
    
    translate([0, 0, 0]) rounded_cube([38, 20, h+1], r=1.5);
    
    for (x = [-36, 36]) for (y = [-34, 34]) {
      translate([x, y, 0]) cylinder(r=1.5, h=10, center=true);
    }
  };
}

module wheel() {
  $fn = 100;
  r = 105; h = 5;
  rotate([0, 90, 0]) union() {
    translate([0, 0, 0]) difference() {
      cylinder(r=r/2, h=h, center=true);
      cylinder(r=r/2-5, h=h+1, center=true);
    };
    
    difference() {
      cylinder(r=9, h=h, center=true);
      
      intersection() {
        cylinder(r=5/2, h=h+1, center=true);
        cube([3.5, 10, h+1], center=true);
      };
    }
    
    for (x = [0:360 / 7.:360]) for (y=[-7, 0, 7]) {
      rotate(x) translate([y, 0, 0]) hull() {
        translate([0,     5, -(h-3)/2]) cube([1.5, 1e-3, 3], center=true);
        translate([0, r/2-5, -(h-3)/2]) cube([1.5, 1e-3, 3], center=true);
      };
    }
  };
};

module robot() {
  main_board();
  % translate([0, +20, 3.5]) cube([35, 31, 1], center=true);
  % translate([0, -20, 3.5]) cube([35, 31, 1], center=true);

  translate([0, 0, 31.5]) controller_board();
  % translate([0, -25, 33.5]) cube([65, 30, 1], center=true);
  % translate([0, +24, 33.5]) cube([65, 27, 1], center=true);
  
  translate([0, 0, -24.5]) battery_board();
  % translate([0, 45, -3]) cube([30, 3, 30], center=true);
  % translate([0, 47, 0]) rotate([90, 0, 0]) cylinder(r=5, h=7, center=true);

  translate([+55, 0, 5]) mirror([0, 0, 0]) wheel();
  translate([-55, 0, 5]) mirror([1, 0, 0]) wheel();
}

// controller_board();
// main_board();
// battery_board();
// rotate([0, -90, 0]) wheel();

robot();

