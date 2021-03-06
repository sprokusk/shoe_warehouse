require('bundler/setup')
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

get('/') do
  @brands = Brand.all().order('name ASC')
  @stores = Store.all().order('name ASC')
  erb(:index)
end

get('/stores/new') do
  erb(:store_form)
end

get('/brands/new') do
  erb(:brand_form)
end

get('/autogenerate') do
  footlocker = Store.create(name: 'Foot Locker', location: '9459 SW Washington St, Tigard, OR 97223', phone: '503-684-2053', open_time: '9', close_time: '8');
  champs = Store.create(name: 'Champs', location: '12000 SE 82nd Ave, Happy Valley, OR 97086', phone: '503-772-9012', open_time: '7', close_time: '10');
  adidas = Brand.create(name: 'Adidas', image: 'http://logos-download.com/wp-content/uploads/2016/03/Adidas_Originals_logo.png')
  nike = Brand.create(name: 'Nike', image: 'http://www.screenitltd.com/sites/default/files/brands/nike-logo.png')
  timberland = Brand.create(name: 'Timberland', image: 'http://images.theexecutiveadvertising.com/images/manflogo/timberland.png')
  reebock = Brand.create(name: 'Reebock', image: 'http://www.findthatlogo.com/wp-content/uploads/2011/09/reebok-logo.jpg')
  footlocker.brands.push(nike)
  footlocker.brands.push(timberland)
  champs.brands.push(adidas)
  redirect "/"
end

get('/stores/:id/edit') do
  @store = Store.find(params['id'])
  @brands = Brand.all.order('id ASC')
  @unused_brands = @brands - @store.brands
  erb(:store_edit)
end

get('/search') do
  if Store.includes(:brands).where('brands.name' => params['brand_name']).any?
    @matched_stores = Store.includes(:brands).where('brands.name' => params['brand_name']).all()
    @brand = Brand.find_by_name(params['brand_name'])
    @brands = Brand.all()
    erb(:search)
  else
    redirect "/"
  end
end

post('/stores/new') do
  @store = Store.create(name: params['name'], location: params['location'], phone: params['phone'], open_time: params['open_time'], close_time: params['close_time']);
  redirect "/"
end

patch('/stores/:id') do
  @store = Store.find(params['id'])
  @store.update(name: params['name'], location: params['location'], phone: params['phone'], open_time: params['open_time'], close_time: params['close_time'])
  redirect "stores/#{@store.id()}/edit"
end

delete ('/stores/:id/delete') do
  @store = Store.find(params['id']).destroy()
  redirect "/"
end

post('/brands/new') do
  Brand.create(name: params['brand_name_input'], image: params['image'])
  redirect "/"
end

post('/brands/assigned/new') do
  @store = Store.find(params['store_id'])
  if Brand.find_by_name(params['brand_name'])
    brand = Brand.find_by_name(params['brand_name'])
  else
    brand = Brand.create(name: params['brand_name'], image: params['image'])
  end
  @store.brands.push(brand)
  redirect "stores/#{params['store_id']}/edit"
end

post('/brands/unassigned/new') do
  @store = Store.find(params['store_id'])
  if Brand.find_by_name(params['brand_name_new'])
    brand = Brand.find_by_name(params['brand_name_new'])
  elsif params['brand_name_new'] == ""
    redirect "/"
  else
    brand = Brand.create(name: params['brand_name_new'], image: params['image'])
  end
  @store.brands.push(brand)
  redirect "stores/#{params['store_id']}/edit"
end
