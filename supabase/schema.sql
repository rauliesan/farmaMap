-- ============================================================
-- FarmaMap Sevilla - Database Schema
-- Execute this SQL in the Supabase SQL Editor
-- ============================================================

-- Enable earthdistance extension (requires cube)
create extension if not exists cube;
create extension if not exists earthdistance;

-- Create the farmacias table
create table if not exists farmacias (
  id bigserial primary key,
  nombre text not null,
  direccion text not null,
  localidad text,
  codigo_postal text,
  lat double precision,
  lng double precision,
  created_at timestamptz default now()
);

-- Index for geospatial queries
create index if not exists farmacias_geo_idx on farmacias using gist (
  ll_to_earth(lat, lng)
);

-- Index for text search
create index if not exists farmacias_nombre_idx on farmacias using gin (
  to_tsvector('spanish', nombre)
);

-- Index for address search
create index if not exists farmacias_direccion_idx on farmacias using gin (
  to_tsvector('spanish', direccion)
);

-- Function to find nearby pharmacies within a radius (in meters)
create or replace function farmacias_cercanas(
  user_lat double precision,
  user_lng double precision,
  radio_metros double precision default 2000
)
returns setof farmacias as $$
  select * from farmacias
  where lat is not null and lng is not null
    and lat != 0 and lng != 0
    and earth_distance(
      ll_to_earth(user_lat, user_lng),
      ll_to_earth(lat, lng)
    ) <= radio_metros
  order by earth_distance(
    ll_to_earth(user_lat, user_lng),
    ll_to_earth(lat, lng)
  ) asc;
$$ language sql stable;

-- Enable Row Level Security with public read access
alter table farmacias enable row level security;

create policy "Lectura pública"
  on farmacias
  for select
  using (true);
