-- Zone odgovaraju preset pozicijama u aplikaciji (preset_positions_screen.dart).
-- zone_name je kljuc po kojem aplikacija mapira preset poziciju na zone_id,
-- pa nazivi moraju ostati identicni.
-- x_position / y_position su postoci (0-100) slike terena assets/court/half_court.png.

INSERT INTO zones (zone_name, description, x_position, y_position, display_order)
VALUES
('Left Corner 3',   'Three-point shot from the left corner, along the baseline.',   15.00, 11.00,  1),
('Right Corner 3',  'Three-point shot from the right corner, along the baseline.',  85.00, 11.00,  2),
('Left Wing 3',     'Three-point shot from the left wing, above the break.',        23.00, 52.00,  3),
('Right Wing 3',    'Three-point shot from the right wing, above the break.',       77.00, 52.00,  4),
('Top of the Key',  'Three-point shot straight on, at the top of the arc.',         50.00, 74.00,  5),
('Left Elbow',      'Midrange shot from the left corner of the free throw line.',   36.00, 51.00,  6),
('Right Elbow',     'Midrange shot from the right corner of the free throw line.',  64.00, 51.00,  7),
('Left Baseline',   'Midrange shot from the left baseline, outside the paint.',     24.00, 13.00,  8),
('Right Baseline',  'Midrange shot from the right baseline, outside the paint.',    76.00, 13.00,  9),
('Nail',            'Midrange shot from just behind the free throw line.',          50.00, 63.00, 10),
('Left Block',      'Close range shot from the left low post block.',               38.50, 21.00, 11),
('Right Block',     'Close range shot from the right low post block.',              61.50, 21.00, 12),
('Restricted Area', 'Finish at the rim, inside the restricted area.',               50.00, 17.00, 13),
('Free Throw',      'Free throw from the line.',                                    50.00, 53.00, 14),
('Half Court',      'Long range shot from around the half court line.',             50.00, 91.00, 15)
ON CONFLICT DO NOTHING;
