DROP TABLE IF EXISTS shots CASCADE;
DROP TABLE IF EXISTS template_zones CASCADE;
DROP TABLE IF EXISTS trainings CASCADE;
DROP TABLE IF EXISTS training_templates CASCADE;
DROP TABLE IF EXISTS zones CASCADE;
DROP TABLE IF EXISTS friendships CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users(
	user_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	nickname VARCHAR(50) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE,
	password_hash VARCHAR(255) NOT NULL,
	is_verified BOOLEAN DEFAULT FALSE,
	verification_token VARCHAR(255),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE training_templates(
	template_id SERIAL PRIMARY KEY,
	template_name VARCHAR(100) NOT NULL,
	description TEXT,
	total_shots INT NOT NULL CHECK (total_shots >= 0),
	creator_user_id INT,
	is_public BOOLEAN DEFAULT FALSE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (creator_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
	UNIQUE (creator_user_id, template_name)
);

CREATE TABLE zones(
	zone_id SERIAL PRIMARY KEY,
	zone_name VARCHAR(100) NOT NULL UNIQUE,
	description TEXT,
	x_position NUMERIC(5,2),
	y_position NUMERIC(5,2),
	display_order INT NOT NULL UNIQUE,
	is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE trainings(
	training_id SERIAL PRIMARY KEY,
	user_id INT NOT NULL,
	template_id INT,
	training_name VARCHAR(100) NOT NULL,
	started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	finished_at TIMESTAMP,
	duration_minutes INT CHECK (duration_minutes IS NULL OR duration_minutes >= 0),
	notes TEXT,
	FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
	FOREIGN KEY (template_id) REFERENCES training_templates(template_id) ON DELETE SET NULL
);

CREATE TABLE shots(
	shot_id SERIAL PRIMARY KEY,
	training_id INT NOT NULL,
	zone_id INT NOT NULL,
	made BOOLEAN NOT NULL,
	shot_order INT CHECK (shot_order IS NULL OR shot_order > 0),
	notes TEXT,
	shot_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (training_id) REFERENCES trainings(training_id) ON DELETE CASCADE,
	FOREIGN KEY (zone_id) REFERENCES zones(zone_id) ON DELETE RESTRICT,
	UNIQUE (training_id, shot_order)
);

CREATE TABLE template_zones(
	template_zone_id SERIAL PRIMARY KEY,
	template_id INT NOT NULL,
	zone_id INT NOT NULL,
	planned_shots INT NOT NULL CHECK (planned_shots >= 0),
	FOREIGN KEY (template_id) REFERENCES training_templates(template_id) ON DELETE CASCADE,
	FOREIGN KEY (zone_id) REFERENCES zones(zone_id) ON DELETE CASCADE,
	UNIQUE (template_id, zone_id)
);

CREATE TABLE friendships(
	friendship_id SERIAL PRIMARY KEY,
	user_id INT NOT NULL,
	friend_id INT NOT NULL,
	status VARCHAR(20) NOT NULL CHECK (status IN ('pending','accepted','rejected')),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
	FOREIGN KEY (friend_id) REFERENCES users(user_id) ON DELETE CASCADE,
	CHECK (user_id <> friend_id),
	UNIQUE (user_id, friend_id)
);

CREATE INDEX idx_trainings_user ON trainings(user_id);
CREATE INDEX idx_trainings_template ON trainings(template_id);

CREATE INDEX idx_shots_training ON shots(training_id);
CREATE INDEX idx_shots_zone ON shots(zone_id);
CREATE INDEX idx_shots_training_zone ON shots(training_id, zone_id);

CREATE INDEX idx_template_zones_template ON template_zones(template_id);

CREATE INDEX idx_friendships_user ON friendships(user_id);
CREATE INDEX idx_friendships_friend ON friendships(friend_id);