classdef PROfunctions
    %Wszystkie funkcyjki
    %   no wszystkie wszystkie

    properties
        Property1;
    end

    methods (Static)
        %nazwy+usuwanie zbednego spamu
        function obj = naming_data(inputArg1,name)
            names=inputArg1.textdata(5,:);
            inputArg1= rmfield(inputArg1,"textdata");
            inputArg1= rmfield(inputArg1, "colheaders");
            inputArg1.data= array2table(inputArg1.data,"VariableNames",names);
            inputArg1.name=name;
            obj=inputArg1;
        end
        %
        function obj = geo_data(inputArg1,geometric_data,name)
            [row, col] = find(contains(geometric_data.textdata,name));
            inputArg1.B=geometric_data.data(1,col-1);
            inputArg1.AR=geometric_data.data(2,col-1);
            inputArg1.S=geometric_data.data(3,col-1);
            inputArg1.Mo=geometric_data.data(4,col-1);
            inputArg1.lambda= geometric_data.data(5,col-1);
            inputArg1.SCA= geometric_data.data(6,col-1);
            obj= inputArg1;
        end

        function obj = minimum_Rx(inputArg1,inputArg2,mi)
            inputArg1.min(1,2)=100;
            for i=1:41
                x= inputArg2(i,6)-inputArg2(i,3)*mi; %Cx-Cz*mi
                if x<inputArg1.min(1,2)
                    inputArg1.min(1,1)=inputArg2(i,1);
                    inputArg1.min(1,2)=x;
                    inputArg1.min(1,3)=deg2rad(inputArg2(i,1));
                    inputArg1.min(1,4)=inputArg2(i,3);
                end
            end
            obj=inputArg1;
        end
        function obj=optimum(inputArg1,inputArg2,Ciag)
            rho=1.225;
            wspKOWAL=1.3;
            Vmax=0;
            g=9.81;
            Rymax=0;
            for i=1:41
                for V=0:0.1:12
                    Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),V,"linear")*g;
                    Fz= (1/2)*rho*V^2*inputArg2(i,3)*inputArg1.S;
                    Fx=(1/2)*rho*V^2*inputArg2(i,6)*wspKOWAL*inputArg1.S;
                    Rx=(Ps*cos(deg2rad(inputArg2(i,1)))-inputArg1.min(1,3))-Fx*cos(deg2rad(inputArg2(i,1)))-Fz*sin(deg2rad(inputArg2(i,1)));
                    Ry=Fz*cos(deg2rad(inputArg2(i,1)))+Ps*sin(deg2rad(inputArg2(i,1))-inputArg1.min(1,3))-Fx*sin(deg2rad(inputArg2(i,1)));
                    if  (Rx<0) || (Ry<0)
                        break
                    end
                end
                if (Ry>Rymax) && (V>Vmax)
                    Vmax=V;
                    Rymax=Ry;
                    inputArg1.maxw(1)=inputArg2(i,1);
                    inputArg1.maxw(2)=deg2rad(inputArg2(i,1));
                    inputArg1.maxw(3)=inputArg2(i,3);
                    inputArg1.maxw(4)=inputArg2(i,6);
                    inputArg1.maxV= V;
                end
            end
            obj=inputArg1;
        end
        function obj= start_anal(inputArg1,inputArg2,Ciag,mi,timeW,Lstart,Hmin,Lmax)
            rho=1.225;
            ay=0;
            wspKOWAL=1.3;
            g=9.81;
            deltai=0.001;
            inputArg1.PAYLOAD=0;
            if inputArg1.maxw(3)>inputArg1.min(4)
                Czstart=inputArg1.maxw(3);
            else
                Czstart=inputArg1.min(4);
            end
            for m=2.5:0.1:100
                mc=m+inputArg1.Mo;
                Lx=0;
                Ly=0;
                w=0;
                Vx=0;
                V=0;
                alpha=0;
                Q=mc*g;
                alpha_w=deg2rad(inputArg1.maxw(1));
                for i=deltai:deltai:timeW
                    Fz= (1/2)*rho*Vx^2*Czstart*inputArg1.S;
                    Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),V,"linear",'extrap')*g;
                    Rx=Ps-mi*Q-rho*(1/2)*inputArg1.S*V^2*inputArg1.min(1,2)*wspKOWAL;
                    ax=Rx/(mc);
                    Vx=Vx+ax*deltai;
                    V=Vx;
                    Lx=Lx+Vx*deltai;
                    inputArg1.path(int32(i/deltai),1)=i;
                    inputArg1.path(int32(i/deltai),2)=ax;
                    inputArg1.path(int32(i/deltai),3)=ay;
                    inputArg1.path(int32(i/deltai),4)=V;
                    inputArg1.path(int32(i/deltai),5)=Vx;
                    inputArg1.path(int32(i/deltai),6)=w;
                    inputArg1.path(int32(i/deltai),7)=Lx;
                    inputArg1.path(int32(i/deltai),8)=Ly;
                    inputArg1.path(int32(i/deltai),9)=0;
                    inputArg1.path(int32(i/deltai),10)=0;
                    if (Lx>Lstart) || (Fz>1.1^2*Q)
                        iend=i;
                        break
                    end
                end
                if (Lx>Lstart)
                    break
                end
                for i=iend:deltai:timeW
                    Cz=interp1(inputArg2(:,1),inputArg2(:,3),alpha+rad2deg(alpha_w),"linear","extrap");
                    Cx=interp1(inputArg2(:,1),inputArg2(:,6),alpha+rad2deg(alpha_w),"linear","extrap");
                    Fz= (1/2)*rho*V^2*Cz*inputArg1.S;
                    Fx=(1/2)*rho*V^2*Cx*wspKOWAL*inputArg1.S;
                    ax=(Ps*cos(alpha_w-inputArg1.min(1,3))-Fx*cos(alpha_w)-Fz*sin(alpha_w))/mc;
                    ay=(Fz*cos(alpha_w)+Ps*sin(alpha_w-inputArg1.min(1,3))-Fx*sin(alpha_w)-Q)/mc;
                    Vx=Vx+ax*deltai;
                    w=ay*deltai+w;
                    Lx=Lx+V*deltai;
                    Ly=Ly+w*deltai;
                    alpha=rad2deg(-atan(w/Vx));
                    V=Vx*cos(alpha_w)+abs(sin(alpha_w))*w;
                    Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),V,"linear",'extrap')*g;
                    inputArg1.path(int32(i/deltai),1)=i;
                    inputArg1.path(int32(i/deltai),2)=ax;
                    inputArg1.path(int32(i/deltai),3)=ay;
                    inputArg1.path(int32(i/deltai),4)=V;
                    inputArg1.path(int32(i/deltai),5)=Vx;
                    inputArg1.path(int32(i/deltai),6)=w;
                    inputArg1.path(int32(i/deltai),7)=Lx;
                    inputArg1.path(int32(i/deltai),8)=Ly;
                    inputArg1.path(int32(i/deltai),9)=Cz;
                    inputArg1.path(int32(i/deltai),10)=alpha;
                    if  (Ly>Hmin) || (w<0) || ((ax<0) && (V<inputArg1.maxV)) || (Lx>Lmax)
                        break
                    end
                end
                if (w<0) || ((ax<0) && (V<inputArg1.maxV)) || (Lx>Lmax) || (i==timeW)
                    break
                else
                    inputArg1.PAYLOAD=m;
                    inputArg1.mTOW=mc;
                end
            end
            VarNames={'time','ax','ay','V','Vx','w','Lx','Ly','Cz','alpha'};
            inputArg1.pathT=array2table(inputArg1.path,"VariableNames",VarNames);
            obj=inputArg1;
        end
        function obj = final_points(inputArg1)
            inputArg1.WS=2^(1+0.0833333*inputArg1.B/5);
            inputArg1.FS=inputArg1.PAYLOAD(1)*2.20462/2;
            inputArg1.FFS= 3*inputArg1.FS+inputArg1.WS;
            obj=inputArg1;
        end
    end
end




