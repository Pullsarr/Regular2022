classdef testing
    %% Wszystkie funkcje wymagane do uruchamienia programu obliczającego start
    %  naming_data - przygotowanie odpowiednich nazw
    %  geo_data - wczytanie danych geometrycznych dla każdej konfiugracji
    %  minimum_RX - wyznaczenie najlepszego kąta zaklinowania kadłuba
    % start_anal- cała analiza startu podzielona na 4 fazy
    % final_points - wyznaczenie punktów na zawody SAE Regular 2022
    % Wykresiczki - wykresy do dokumentacji

    properties
        Property1;
    end

    methods (Static)
        %nazwy+usuwanie zbednego spamu
        function obj = naming_data(Config,name)
            %% wczytywanie danych, usuwanie smieci, robienie pożytecznych wektorow
            names=Config.textdata(5,:);
            Config= rmfield(Config,"textdata");
            Config= rmfield(Config, "colheaders");
            Config.dataT= array2table(Config.data,"VariableNames",names);
            Config.alpha=deg2rad(Config.data(:,1));
            Config.Cz=Config.data(:,3);
            Config.Cx=Config.data(:,6);
            Config.name=name;
            obj=Config;
        end
        %
        function obj = geo_data(Config,geometric_data,name)
            %% uzupełnienie danych geoemtrycznych ktorych nie ma w txt
            [row, col] = find(contains(geometric_data.textdata,name),1,"first");
            Config.geo.B=geometric_data.data(1,col-1);
            Config.geo.AR=geometric_data.data(2,col-1);
            Config.geo.S=geometric_data.data(3,col-1);
            Config.geo.Mo=geometric_data.data(4,col-1);
            Config.geo.lambda= geometric_data.data(5,col-1);
            Config.geo.SCA= geometric_data.data(6,col-1);
            obj= Config;
        end

        function obj = minimum_Rx(Config,mi)
            %obliczanie optymalnego współczynnika k= Cx-Cz*mi
            Config.min.k=100;
            for i=1:height(Config.data)
                k= Config.Cx(i)-Config.Cz(i)*mi; %Cx-Cz*mi
                if k<Config.min.k
                    Config.min.alpha=Config.alpha(i);
                    Config.min.k=k;
                    Config.min.Cz=Config.Cz(i);
                    Config.min.Cx=Config.Cx(i);
                end
            end
            obj=Config;
        end
        function obj= start_anal(Config,Ciag,mi,timeW,Lstart,MFV,Rot_angle,Rot_time,Hmin,Lmax,wspKOWAL)
            rho=1.225;
            g=9.81;
            deltai=0.001;
            Config.PAYLOAD=0;
            S=Config.geo.S;
            alpha=0;
            for PAYLOAD=1:0.1:100
                mTOW=PAYLOAD+Config.geo.Mo;
                Vx=0;
                Vy=0;
                Lx=0;
                Ly=0;
                Q=mTOW*g;
                alphaw=0;
                Vod=1.2*sqrt(2*Q/(rho*S*Config.min.Cz));
                %% I faza- rozbieg
                for i=deltai:deltai:timeW
                    Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),Vx,"linear",'extrap')*g;
                    Rx=Ps-mi*Q-(1/2)*rho*Vx^2*S*Config.min.k*wspKOWAL;
                    ax=Rx/(mTOW);
                    Vx=Vx+ax*deltai;
                    V=Vx;
                    Lx=Lx+Vx*deltai;
                    if (Lx>Lstart) || (V>Vod)
                        i1=i;
                        break
                    end
                end
                if (Lx>Lstart)
                    Config.Erorr= 'R22 exceeded limit of starting distance';
                    break
                end
                %% II faza- rozpędzanie
                for i=i1:deltai:timeW
                    Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),Vx,"linear",'extrap')*g;
                    Cz= interp1(Config.alpha,Config.Cz,alpha+Config.min.alpha,"linear","extrap");
                    Cx= interp1(Config.alpha,Config.Cx,alpha+Config.min.alpha,"linear","extrap");
                    Fz= (1/2)*rho*V^2*Cz*S;
                    Fx= (1/2)*rho*V^2*Cx*S;
                    Rx=Ps-Fx*cos(alpha)-Fz*sin(alpha);
                    Ry=Fz*cos(alpha)-Q-Fx*sin(alpha);
                    ax=Rx/mTOW;
                    ay=Ry/mTOW;
                    Vx=Vx+ax*deltai;
                    Vy=Vy+ay*deltai;
                    V=sqrt(Vx^2+Vy^2);
                    alpha=-atan(Vy/Vx);
                    Lx=Lx+Vx*deltai;
                    Ly=Ly+Vy*deltai;
                    if (V>MFV) || (ax<0)
                        i2=i;
                        L2=Lx;
                        break
                    end
                end
                if (ax<0)
                    Config.Save=V;
                    Config.Erorr= 'R22 could not speed up to MFV';
                    break
                end
                %% III faza- rotacja
                for i=i2:deltai:timeW
                    Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),Vx,"linear",'extrap')*g;
                    Cz= interp1(Config.alpha,Config.Cz,alphaw+alpha+Config.min.alpha,"linear","extrap");
                    Cx= interp1(Config.alpha,Config.Cx,alphaw+alpha+Config.min.alpha,"linear","extrap");
                    Fz= (1/2)*rho*V^2*Cz*S;
                    Fx= (1/2)*rho*V^2*Cx*S;
                    Rx=Ps*cos(alphaw)-Fx*cos(alpha)-Fz*sin(alpha);
                    Ry=Fz*cos(alpha)+Ps*sin(alphaw)-Q-Fx*sin(alpha);
                    ax=Rx/mTOW;
                    ay=Ry/mTOW;
                    Vx=Vx+ax*deltai;
                    Vy=Vy+ay*deltai;
                    V=sqrt(Vx^2+Vy^2);
                    alpha=-atan(Vy/Vx);
                    Lx=Lx+Vx*deltai;
                    Ly=Ly+Vy*deltai;
                    if i<=(i2+Rot_time) && (V>MFV)
                        alphaw=((i-i2)/Rot_time)*deg2rad(Rot_angle);
                    else
                        i3=i;
                        break
                    end
                end
                if V<MFV
                    Config.Erorr= 'R22 could not maintain speed during rotation';
                    break
                end
                %% IV faza- wznoszenie
                for i=i3:deltai:timeW
                    Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),Vx,"linear",'extrap')*g;
                    Cz= interp1(Config.alpha,Config.Cz,alphaw+alpha+Config.min.alpha,"linear","extrap");
                    Cx= interp1(Config.alpha,Config.Cx,alphaw+alpha+Config.min.alpha,"linear","extrap");
                    Fz= (1/2)*rho*V^2*Cz*S;
                    Fx= (1/2)*rho*V^2*Cx*S;
                    Rx=Ps*cos(alphaw)-Fx*cos(alpha)-Fz*sin(alpha);
                    Ry=Fz*cos(alpha)+Ps*sin(alphaw)-Q-Fx*sin(alpha);
                    ax=Rx/mTOW;
                    ay=Ry/mTOW;
                    Vx=Vx+ax*deltai;
                    Vy=Vy+ay*deltai;
                    V=sqrt(Vx^2+Vy^2);
                    alpha=-atan(Vy/Vx);
                    Lx=Lx+Vx*deltai;
                    Ly=Ly+Vy*deltai;
                    if (Ly>Hmin) || (Lx>Lmax+L2) || (V<MFV)
                        break
                    end
                end
                if (Lx>Lmax+L2)
                    Config.Erorr= 'R22 could not climb in limiting distance';
                    break
                elseif (V<MFV)
                    Config.Erorr= 'R22 could not maintain speed during climb';
                    break
                end
            end
            Config.PAYLOAD=PAYLOAD;
            obj=Config;
        end
        function obj = final_points(Config)
            Config.WS=2^(1+0.0833333*Config.B/5);
            Config.FS=Config.PAYLOAD(1)*2.20462/2;
            Config.FFS= 3*Config.FS+Config.WS;
            obj=Config;
        end
    end
end




