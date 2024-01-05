# llama2 -> llama2 on cpu with 16GB RAM

'''bash
cd ../llama/

# ... download models ...

pip install accelerate
python -m transformers.models.llama.convert_llama_weights_to_hf \
    --model_size 7B \
    --input_dir llama-2-7b-chat/ \
    --output_dir llama-2-7b-chat-hf/

cd ../llama.cpp/
python3 -m pip install -r requirements.txt
mkdir models/7B
python3 convert.py \
    ../llama/llama-2-7b-chat-hf/ \
    --outfile models/7B/ggml-model-f16.bin \
    --outtype f16 \
    --vocab-dir ../llama/llama-2-7b-chat-hf/

make clean
# make LLAMA_OPENBLAS=1
# make LLAMA_CLBLAST=1
make
./quantize ./models/7B/ggml-model-f16.bin ./models/7B/ggml-model-q4_0.bin q4_0
./main -m ./models/7B/ggml-model-q4_0.bin -n 1024 --repeat_penalty 1.0 --color -i -r "User:" -f ./prompts/chat-with-bob.txt
'''


