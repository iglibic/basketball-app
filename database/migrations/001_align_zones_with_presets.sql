-- Uskladuje tablicu zones s preset pozicijama u aplikaciji.
-- Naziv zone (zone_name) je kljuc po kojem aplikacija mapira preset poziciju
-- na zone_id, pa nazivi moraju biti identicni onima u preset_positions_screen.dart.
--
-- Skripta je idempotentna i moze se pokrenuti vise puta.

BEGIN;

-- 1. Preimenuj postojece zone u nazive koje aplikacija koristi
UPDATE zones SET zone_name = 'Top of the Key' WHERE zone_name = 'Top of Key 3';
UPDATE zones SET zone_name = 'Left Elbow'     WHERE zone_name = 'Left Midrange';
UPDATE zones SET zone_name = 'Right Elbow'    WHERE zone_name = 'Right Midrange';

-- 2. Privremeno makni display_order iz raspona 1..15 da izbjegnemo
--    krsenje UNIQUE ogranicenja dok postavljamo konacni redoslijed
UPDATE zones SET display_order = display_order + 100 WHERE display_order < 100;

-- 3. Dodaj zone koje postoje u aplikaciji, a nema ih u bazi
INSERT INTO zones (zone_name, description, x_position, y_position, display_order)
VALUES
  ('Left Baseline',   'Midrange shot from the left baseline, outside the paint.',  24.00, 13.00, 208),
  ('Right Baseline',  'Midrange shot from the right baseline, outside the paint.', 76.00, 13.00, 209),
  ('Nail',            'Midrange shot from just behind the free throw line.',       50.00, 63.00, 210),
  ('Left Block',      'Close range shot from the left low post block.',            38.50, 21.00, 211),
  ('Right Block',     'Close range shot from the right low post block.',           61.50, 21.00, 212),
  ('Restricted Area', 'Finish at the rim, inside the restricted area.',            50.00, 17.00, 213),
  ('Half Court',      'Long range shot from around the half court line.',          50.00, 91.00, 214)
ON CONFLICT DO NOTHING;

-- 4. Postavi konacni redoslijed i koordinate.
--    x_position / y_position su postoci (0-100) slike terena assets/court/half_court.png.
UPDATE zones AS z
SET display_order = v.display_order,
    x_position    = v.x_position,
    y_position    = v.y_position
FROM (VALUES
  ('Left Corner 3',    1, 15.00, 11.00),
  ('Right Corner 3',   2, 85.00, 11.00),
  ('Left Wing 3',      3, 23.00, 52.00),
  ('Right Wing 3',     4, 77.00, 52.00),
  ('Top of the Key',   5, 50.00, 74.00),
  ('Left Elbow',       6, 36.00, 51.00),
  ('Right Elbow',      7, 64.00, 51.00),
  ('Left Baseline',    8, 24.00, 13.00),
  ('Right Baseline',   9, 76.00, 13.00),
  ('Nail',            10, 50.00, 63.00),
  ('Left Block',      11, 38.50, 21.00),
  ('Right Block',     12, 61.50, 21.00),
  ('Restricted Area', 13, 50.00, 17.00),
  ('Free Throw',      14, 50.00, 53.00),
  ('Half Court',      15, 50.00, 91.00)
) AS v(zone_name, display_order, x_position, y_position)
WHERE z.zone_name = v.zone_name;

COMMIT;
