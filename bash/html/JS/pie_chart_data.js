window.onload = function () {
				
				/**** dynamic data needs to be added below ****/
                var r = Raphael("holder"),
                    pie = r.piechart(320, 240, 100, [55, 20, 32, 13, 5, 1, 2, 10], { legend: ["%%.%% - ColdFusion (I wish)", "%%.%% - Javascript", "%%.%% - c#",], legendpos: "west", href: ["http://raphaeljs.com", "http://g.raphaeljs.com"]});
				/**** dynamic data needs to be added above ****/
				
				
				
                r.text(320, 100, "Reported language usage in public GitHub repositories").attr({ font: "20px Tahoma" });
                pie.hover(function () {
                    this.sector.stop();
                    this.sector.scale(1.1, 1.1, this.cx, this.cy);

                    if (this.label) {
                        this.label[0].stop();
                        this.label[0].attr({ r: 7.5 });
                        this.label[1].attr({ "font-weight": 800 });
                    }
                }, function () {
                    this.sector.animate({ transform: 's1 1 ' + this.cx + ' ' + this.cy }, 500, "bounce");

                    if (this.label) {
                        this.label[0].animate({ r: 5 }, 500, "bounce");
                        this.label[1].attr({ "font-weight": 400 });
                    }
                });
            };