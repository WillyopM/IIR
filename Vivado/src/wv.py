import json
# sample = [90, 49, 0, -49, -90, -117, -127, -117, -90, -49, 0, 49, 90, 117, 127, 117]
sample = [ 127, 117, 90, 49, 0, -49, -90, -117, -127, -117, -90, -49, 0, 49, 90, 117]
cycles = 39
outmode0 = [0 for _ in range(cycles)]

xn = [0] * 16
xn_clk = [0] * 16
sadder = [[0 for _ in range(cycles)] for _ in range(8)]
sadder_clk = [[0 for _ in range(cycles)] for _ in range(8)]

mult = [0] * 8
mult_clk = [0] * 8

K = [2, 8, 13, 16, 16, 13, 8, 2]
# K = [3,11,13, 17, 19, 15, 21, 9]
# K = [8,-2,3,-4,4,-3,2,9]

## clock main loop
for i in range(0, cycles):
    ## Registre à décalage
    for j in range(len(xn) - 1, 0, -1):
        xn[j] = xn[j-1]
    xn[0] = sample[i % 16]
    
    
    ## Multiplier (remarque : utilisez xn_clk ou xn selon ce que vous souhaitez)
    for k in range(8):
        mult[k] = K[k] * xn_clk[2 * k + 1]  # vérifiez si l'indexation est correcte
    
    
    ## Accumulation en cascade dans chaque "adder"
    sadder[0][i] = int(mult_clk[0] + 0)
    for h in range(1, 8):
        sadder[h][i] = mult_clk[h] + sadder_clk[h - 1][i - 1]
    
    
    ## Mise à jour des valeurs pour le prochain cycle
    for l in range(8):
        for m in range(cycles):
            sadder_clk[l][m] = sadder[l][m]
        mult_clk[l] = mult[l]
    for n in range(16):  
        xn_clk[n] = xn[n]
        
    outmode0[i] = sample[i % 16] << 8


print(xn)
print(f"Sortie : {outmode0}")
print(f"adder[0] : {sadder[0]}")
print(f"adder[1] : {sadder[1]}")
print(f"adder[2] : {sadder[2]}")
print(f"adder[3] : {sadder[3]}")
print(f"adder[4] : {sadder[4]}")
print(f"adder[5] : {sadder[5]}")
print(f"adder[6] : {sadder[6]}")
print(f"adder[7] : {sadder[7]}")

print(xn)
print(f"Sortie : {outmode0}")

for o in range(8):   
    formatted_values = [
        "{:.4f}".format(
            (value / (1 << 12)) if (value >> 12) == 0 else
            (-1 * (abs(value) / (1 << 12))) if (value >> 12) == -1 else
            (float(value >> 12) + (value % (1 << 12)) / (1 << 12))
        )
        for value in sadder[o]
    ]
    print(f"adder[{o}] : {formatted_values}")
    
with open("data.json", "w") as f:
    json.dump(formatted_values, f, indent=4)    
    for p in range(8):
        my_data = {f"adder{p}" :[ str(x) for x in sadder[p] ] }
        json.dump(my_data, f, indent=4)

    
    # for value in sadder[o]:
    #         if(value >> 12) == 0:
    #             print(f"adder[{o}] :  {float(value) / float(1 << 12)}")
    #         elif (value >> 12) == -1:
    #             print(f"adder[{o}] :  {-1 * float(value) / float(1 << 12)}")
    #         else:
    #             print(f"adder[{o}] :  {float(value >> 12) + float(value) / float(1 << 12)}")
                
# print(f"adder[0] :  {[float(value >> 12) + float(value) / float(1 << 12) for value in sadder[0]]}")
# print(f"adder[1] :  {[float(value >> 12) + float(value / float(1 << 12)) for value in sadder[1]]}")
# print(f"adder[2] :  {[float(value >> 12) + float(value / float(1 << 12)) for value in sadder[2]]}")
# print(f"adder[3] :  {[float(value >> 12) + float(value / float(1 << 12)) for value in sadder[3]]}")
# print(f"adder[4] :  {[float(value >> 12) + float(value / float(1 << 12)) for value in sadder[4]]}")
# print(f"adder[5] :  {[float(value >> 12) + float(value / float(1 << 12)) for value in sadder[5]]}")
# print(f"adder[6] :  {[float(value >> 12) + float(value / float(1 << 12)) for value in sadder[6]]}")
# print(f"adder[7] :  {[float(value >> 12) + float(value / float(1 << 12)) for value in sadder[7]]}")