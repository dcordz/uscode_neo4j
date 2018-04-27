class NodesController < ApplicationController

  def index
    Node.all
  end

end
