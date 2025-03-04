//������������������������������������������������������������������������������
 // �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D g_texture : register(t0); //�e�N�X�`���[
SamplerState g_sampler : register(s0); //�T���v���[

Texture2D g_toon_texture : register(t1); //�e�N�X�`���[
SamplerState g_toon_sampler : register(s1); //�T���v���[

//������������������������������������������������������������������������������
// �R���X�^���g�o�b�t�@
// DirectX �����瑗�M����Ă���A�|���S�����_�ȊO�̏����̒�`
//������������������������������������������������������������������������������
cbuffer gModel : register(b0)
{
    float4x4 matWVP; // ���[���h�E�r���[�E�v���W�F�N�V�����̍����s��
    float4x4 matW; //���[���h�ϊ��}�g���N�X
    float4x4 matNormal; // ���[���h�s��
    float4 diffuseColor; //�}�e���A���̐F���g�U���ˌW��
    float4 factor;
    float4 ambientColor;
    float4 specularColor;
    float4 shininess;

    bool isTextured; //�e�N�X�`���[���\���Ă��邩�ǂ���
};

cbuffer gStage : register(b1)
{
    float4 lightPosition;
    float4 eyePosition;
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
    float4 pos : SV_POSITION; //�ʒu
    float2 uv : TEXCOORD; //UV���W
    float4 color : COLOR; //�F�i���邳�j
    float4 normal : NORMAL;
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
	//�s�N�Z���V�F�[�_�[�֓n�����
    VS_OUT outData;

	//���[�J�����W�ɁA���[���h�E�r���[�E�v���W�F�N�V�����s���������
	//�X�N���[�����W�ɕϊ����A�s�N�Z���V�F�[�_�[��
    outData.pos = mul(pos, matWVP);
    outData.uv = uv;
    
    outData.normal = mul(normal, matNormal);
    
	//float4 light = float4(0, 1, -1, 0);
    float4 light = lightPosition;
    light = normalize(light);
    outData.color = clamp(dot(normal, light), 0, 1);
    
	//�܂Ƃ߂ďo��
    return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
    float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
    float4 ambentSource = float4(0.2, 0.2, 0.2, 1.0);
    float4 diffuse;
    float4 ambient;
    
    float NL = saturate(dot(inData.normal, normalize(lightPosition)));
    
    float2 uv = float2(NL, 0);
    float4 tI = g_toon_texture.Sample(g_sampler, uv);
    
    //float4 n1 = float4(1.0f / 4.0f, 1.0f / 4.0f, 1.0f / 4.0f, 1.0f);
    //float4 n2 = float4(2.0f / 4.0f, 2.0f / 4.0f, 2.0f / 4.0f, 1.0f);
    //float4 n3 = float4(3.0f / 4.0f, 3.0f / 4.0f, 3.0f / 4.0f, 1.0f);
    //float4 n4 = float4(4.0f / 4.0f, 4.0f / 4.0f, 4.0f / 4.0f, 1.0f);
    //float4 tI = 0.1 * step(n1, NL) + 0.2 * step(n2, NL)
    //            + 0.3 * step(n3, NL) + 0.4 * step(n4, NL);
    //float4 tI = 0.1 * step(n1, inData.color) + 0.3 * step(n2, inData.color)
    //            + 0.3 * step(n3, inData.color);
    
    if (isTextured == false)
    {
        diffuse = diffuseColor * tI;
        ambient = diffuseColor * ambentSource;
    }
    else
    {
        diffuse = g_texture.Sample(g_sampler, inData.uv) * tI;
        ambient = g_texture.Sample(g_sampler, inData.uv) * ambentSource;

    }
    
    //float4 ret = diffuse + ambient;
    //if (NE > -0.1 && NE < 0.1)
    //{
    //    ret = float4(0, 0, 0, 1);
    //}
    //return ret;
    
	//return g_texture.Sample(g_sampler, inData.uv);// (diffuse + ambient);]
	//float4 diffuse = lightSource * inData.color;
	//float4 ambient = lightSource * ambentSource;
    return diffuse + ambient;
    //return tI;
    //float2 uv = float2(tI.x, 0);
    //return g_toon_texture.Sample(g_sampler, uv) + diffuse + ambient;
}