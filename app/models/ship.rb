class Ship < ApplicationRecord
    belongs_to :manufacturer, optional: true
    has_one_attached :image_topdown
    has_many :users, through: :userships
    validates :model, uniqueness: true

    def code
        if self.model.include?("Starfarer") 
            code = 'SF'  
        elsif self.model.include?("100i")
            code = '10'
            
            elsif self.model.include?("125a")
            code = '12'
            
            elsif self.model.include?("135c")
            code = '13'
            
            elsif self.model.include?("300i")
            code = '30'
            
            elsif self.model.include?("315p")
            code = '31'
            
            elsif self.model.include?("325a")
            code = '32'
            
            elsif self.model.include?("350r")
            code = '35'
            
            elsif self.model.include?("400i")
            code = '40'
            
            elsif self.model.include?("600")
            code = '60'
            
            elsif self.model.include?("600")
            code = '6E'
            
            elsif self.model.include?("600")
            code = '6T'
            
            elsif self.model.include?("85")
            code = '85'
            
            elsif self.model.include?("890")
            code = '89'
            
            elsif self.model.include?("A2")
            code = 'A2'
            
            elsif self.model.include?("Ares")
            code = 'IN'
            
            elsif self.model.include?("Ares")
            code = 'IO'
            
            elsif self.model.include?("Arrow")
            code = 'AR'
            
            elsif self.model.include?("Aurora")
            code = 'AU'
            
            elsif self.model.include?("Avenger")
            code = 'AV'
            elsif self.model.include?("Ballista")
            code = 'BA'
            
            elsif self.model.include?("Ballista")
            code = 'BA'
            
            elsif self.model.include?("Ballista")
            code = 'BA'
            
            elsif self.model.include?("Blade")
            code = 'BL'
            elsif self.model.include?("Buccaneer")
            code = 'BU'
            elsif self.model.include?("C2")
            code = 'C2'
            elsif self.model.include?("C8")
            code = 'C8'
            elsif self.model.include?("C8")
            code = 'C8'
            elsif self.model.include?("Carrack")
            code = 'CA'
            elsif self.model.include?("Caterpillar")
            code = 'CP'
            elsif self.model.include?("Constellation")
            code = 'CO'
            elsif self.model.include?("Cutlass")
            code = 'CU'
            elsif self.model.include?("Cutter")
            code = 'CT'
            elsif self.model.include?("Cyclone")
            code = 'CY'
            elsif self.model.include?("Defender")
            code = 'DF'
            elsif self.model.include?("Dragonfly")
            code = 'DR'
            elsif self.model.include?("Eclipse")
            code = 'EC'
            elsif self.model.include?("F7")
            code = 'F7'
            elsif self.model.include?("F8")
            code = 'F8'
            elsif self.model.include?("Freelancer")
            code = 'FR'
            elsif self.model.include?("Gladiator")
            code = 'GL'
            elsif self.model.include?("Gladius")
            code = 'GA'
            elsif self.model.include?("Glaive")
            code = 'GV'
            elsif self.model.include?("Hammerhead")
            code = 'HM'
            elsif self.model.include?("Hawk")
            code = 'HK'
            elsif self.model.include?("Herald")
            code = 'HR'
            elsif self.model.include?("HoverQuad")
            code = 'HQ'
            elsif self.model.include?("Hurricane")
            code = 'HC'
            elsif self.model.include?("Khartu-al")
            code = 'KA'
            elsif self.model.include?("Kraken")
            code = 'KR'
            elsif self.model.include?("Yai")
            code = 'YA'
            elsif self.model.include?("M2")
            code = 'M2'
            elsif self.model.include?("M50")
            code = '50'
            elsif self.model.include?("Mantis")
            code = 'MN'
            elsif self.model.include?("Star Runner")
            code = 'MR'
            elsif self.model.include?("Mole")
            code = 'MO'
            elsif self.model.include?("MPUV")
            code = 'UC'
            elsif self.model.include?("Mustang")
            code = 'MU'
            elsif self.model.include?("Nomad")
            code = 'NO'
            elsif self.model.include?("Nova")
            code = 'NV'
            elsif self.model.include?("Nox")
            code = 'NX'
            elsif self.model.include?("P-52")
            code = 'P5'
            elsif self.model.include?("P-72")
            code = 'P7'
            elsif self.model.include?("Prospector")
            code = 'PR'
            elsif self.model.include?("Prowler")
            code = 'PW'
            elsif self.model.include?("PTV")
            code = 'PV'
            elsif self.model.include?("Raft")
                code = 'RA'
            elsif self.model.include?("Razor")
                code = 'RZ'
            elsif self.model.include?("Reclaimer")
                code = 'RL'
            elsif self.model.include?("Redeemer")
                code = 'RD'
            elsif self.model.include?("Reliant")
                code = 'RT'
            elsif self.model.include?("ROC")
                code = 'RO'
            elsif self.model.include?("Sabre")
                code = 'SA'
            elsif self.model.include?("Spartan")
                code = 'SP'
            elsif self.model.include?("Talon")
                code = 'TL'
            elsif self.model.include?("Terrapin")
                code = 'TP'
            elsif self.model.include?("Ursa")
                code = 'UR'
            elsif self.model.include?("Valkyrie")
                code = 'VK'
            elsif self.model.include?("Vanguard")
                code = 'VG'
            elsif self.model.include?("Apollo")
                code = 'AP'
            elsif self.model.include?("Idris")
                code = 'ID'
            elsif self.model.include?("Javelin")
                code = 'JV'
            elsif self.model.include?("Nautilus")
                code = 'NA'
            elsif self.model.include?("Orion")
                code = 'OR'
            elsif self.model.include?("Perseus")
                code = 'PE'
            elsif self.model.include?("Polaris")
                code = 'PO'
            elsif self.model.include?("Scorpius")
                code = 'SC'
            elsif self.model.include?("Starliner")
                code = 'SR'
            elsif self.model.include?("Vulcan")
                code = 'VU'
            elsif self.model.include?("Pioneer")
                code = 'PI'
            elsif self.model.include?("Merchantman")
                code = 'BM'
            elsif self.model.include?("SRV")
                code = 'SV'
            elsif self.model.include?("STV")
                code = 'ST'
            elsif self.model.include?("Vulture")
                code = 'VT'
            elsif self.model.include?("Mule")
                code = 'MU'
            elsif self.model.include?("Crucible")
                code = 'CR'
            elsif self.model.include?("Ranger")
                code = 'RA'
            elsif self.model.include?("Centurian")
                code = 'CE'
            elsif self.model.include?("Liberator")
                code = 'LB'
            elsif self.model.include?("Legionnaire")
                code = 'LG'
            elsif self.model.include?("Corsair")
                code = 'CR'
            elsif self.model.include?("Railen")
                code = 'RA'
            elsif self.model.include?("Endeavor")
                code = 'EN'
            elsif self.model.include?("Hull-A")
                code = 'HA'
            elsif self.model.include?("Hull-B")
                code = 'HB'
            elsif self.model.include?("Hull-C")
                code = 'HC'
            elsif self.model.include?("Hull-D")
                code = 'HD'
            elsif self.model.include?("Hull-E")
                code = 'HE'
            elsif self.model.include?("Odyssey")
                code = 'OD'
            elsif self.model.include?("Expanse")
                code = 'EX'
            elsif self.model.include?("X1")
                code = 'X1'
            elsif self.model.include?("G12")
                code = 'G1'
            elsif self.model.include?("E1")
                code = 'E1'
            elsif self.model.include?("C1")
                code = 'C1'
            elsif self.model.include?("A1")
                code = 'A1'
        end
    end



    def expandedships(user) 
        
        Usership.where(model: self.model, user_id: user.id )
    end

end


