-- Run this whole script once in Supabase > SQL Editor.
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 name text not null,
 quantity integer not null default 0 check(quantity>=0),
 updated_at timestamptz not null default now(),
 unique(user_id,name)
);
create table if not exists public.stock_movements (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 product_id uuid not null references public.products(id) on delete cascade,
 movement_type text not null check(movement_type in ('IN','OUT')),
 quantity integer not null check(quantity>0),
 note text,
 created_at timestamptz not null default now()
);
alter table public.products enable row level security;
alter table public.stock_movements enable row level security;
drop policy if exists "owner reads products" on public.products;
create policy "owner reads products" on public.products for select to authenticated using(user_id=auth.uid());
drop policy if exists "owner updates products" on public.products;
create policy "owner updates products" on public.products for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists "owner inserts products" on public.products;
create policy "owner inserts products" on public.products for insert to authenticated with check(user_id=auth.uid());
drop policy if exists "owner reads history" on public.stock_movements;
create policy "owner reads history" on public.stock_movements for select to authenticated using(user_id=auth.uid());
drop policy if exists "owner inserts history" on public.stock_movements;
create policy "owner inserts history" on public.stock_movements for insert to authenticated with check(user_id=auth.uid());
grant usage on schema public to authenticated;
grant select,insert,update on public.products to authenticated;
grant select,insert on public.stock_movements to authenticated;

create or replace function public.create_my_products()
returns void language plpgsql security invoker set search_path=public
as $$
begin
 insert into public.products(user_id,name)
 values(auth.uid(),'Shirts'),(auth.uid(),'Trousers'),(auth.uid(),'Pants')
 on conflict(user_id,name) do nothing;
end; $$;
grant execute on function public.create_my_products() to authenticated;

create or replace function public.record_stock_movement(
 p_product_id uuid,p_movement_type text,p_quantity integer,p_note text default null
) returns void language plpgsql security invoker set search_path=public
as $$
begin
 if auth.uid() is null then raise exception 'Please login first'; end if;
 if p_quantity is null or p_quantity<=0 then raise exception 'Quantity must be greater than zero'; end if;
 if p_movement_type not in ('IN','OUT') then raise exception 'Invalid movement type'; end if;
 if p_movement_type='IN' then
  update public.products set quantity=quantity+p_quantity,updated_at=now()
  where id=p_product_id and user_id=auth.uid();
 else
  update public.products set quantity=quantity-p_quantity,updated_at=now()
  where id=p_product_id and user_id=auth.uid() and quantity>=p_quantity;
  if not found then raise exception 'Not enough stock, or product not found'; end if;
 end if;
 if not found and p_movement_type='IN' then raise exception 'Product not found'; end if;
 insert into public.stock_movements(user_id,product_id,movement_type,quantity,note)
 values(auth.uid(),p_product_id,p_movement_type,p_quantity,left(p_note,200));
end; $$;
grant execute on function public.record_stock_movement(uuid,text,integer,text) to authenticated;
