CREATE TABLE user_devices_cumulated (
	user_id NUMERIC,
	browser_type TEXT,
	device_activity_datelist DATE[],
	date DATE,
	PRIMARY KEY (user_id, browser_type, date)
)

CREATE TABLE hosts_cumulated (
	host TEXT,
	user_id NUMERIC,
	host_activity_datelist DATE[],
	date DATE,
	PRIMARY KEY (host, user_id, date)
)