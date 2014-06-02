require 'sinatra'
require 'pg'
require 'pry'


def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield (connection)

  ensure
    connection.close
  end
end

################################# SEARCH #####################################
#############################################################################
def search_recipes(query)
  sql = "SELECT recipes.name FROM recipes WHERE recipes.name ILIKE '%$1%'"
  results =  db_connection do |conn|
    conn.exec_params(sql, [query])
  end

  results.to_a
end






################################# INDEX #####################################
#############################################################################


################################# LIST ######################################
#############################################################################
def recipes_list(page)

page_sql = page.to_i
page_sql -= 1
  recipes_list =  db_connection do |conn|
    conn.exec("SELECT recipes.name, recipes.id FROM recipes LIMIT 20 OFFSET (#{page_sql} * 20)")
  end

  recipes_list.to_a
end



################################# RECIPE ####################################
#############################################################################

def find_recipe_info(id)




  sql = "SELECT recipes.name, recipes.description FROM recipes WHERE recipes.id = $1;"

  recipe_info =  db_connection do |conn|
    conn.exec_params(sql, [id])
  end

  recipe_info.to_a.first

end

def find_instructions(id)
  sql = "SELECT recipes.instructions FROM recipes WHERE recipes.id = $1;"

  instructions =  db_connection do |conn|
    conn.exec_params(sql, [id])
  end


  instructions = instructions.to_a.first["instructions"]
    if instructions == nil
      instructions = ["Instructions coming soon."]
    else
      instructions = instructions.split('.')


      #instructions = instructions.reject! { |ins| ins.empty? }
    end
  instructions
end

def find_ingredients(id)
  sql = "SELECT * FROM ingredients WHERE recipe_id = $1;"

  ingredients =  db_connection do |conn|
    conn.exec_params(sql, [id])
  end

  ingredients.to_a
  ingredients_array = []

  ingredients.each do |ingredient|
    ingredients_array << ingredient["name"]
  end
  ingredients_array
end


################################# ROUTES ####################################
#############################################################################

get '/' do
  erb :index
end



get '/recipes' do

  # if params[:q]
  #   #get all recipes
  #   @recipes_list = search_recipes(params[:q])
  # else
  if params[:page] == nil
    page = 1
  else
    page = params[:page].to_i
  end
  @page = params[:page].to_i
  @recipes_list = recipes_list(page)
  erb :'list.html'
end




get '/recipes/:id' do
  page_title = find_recipe_info(params[:id])
  @page_title = page_title["name"]
  @ingredients = find_ingredients(params[:id])
  @instructions = find_instructions(params[:id])
  @recipe_info = find_recipe_info(params[:id])
  erb :'recipes/show.html'
end




