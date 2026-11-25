-- Enable realtime notifications for company shared snapshot revisions.
alter publication supabase_realtime add table public.company_data_snapshots;
