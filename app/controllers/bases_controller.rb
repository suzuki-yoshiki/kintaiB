class BasesController < ApplicationController
   before_action :admin_user, only: :index
    
    def index
      redirect_to user_url unless current_user.admin?
      @bases = Base.all
    end
    
    def new
      @number = Base.where.not(base_number:nil).count
      @number = @number.to_i + 1
      @base = Base.new
    end
    
    def create
        @base = Base.new(base_params)
      if  
        @base.save
        flash[:success] = "拠点情報を追加しました。"
        redirect_to bases_url 
      else
        flash[:danger] = "追加は失敗しました"
        render :new
      end
    end
    
    def edit2
    end
    
    def edit
        @base = Base.find(params[:id])
    end
    
    def update
       @base = Base.find(params[:id])
      if @base.update_attributes(base_params)
         flash[:success] = "拠点情報を更新しました。"
         redirect_to bases_url
      else
         flash[:danger] = "更新は失敗しました。"
         redirect_to bases_url
      end
         
    end
    
    def destroy
      @base = Base.find(params[:id])
      @base.destroy
      flash[:success] = "拠点のデータを削除しました。"
      redirect_to bases_url
    end
    
  private
  
      def base_params
        params.require(:base).permit(:base_name, :base_type, :base_number)
      end
      
      
end
